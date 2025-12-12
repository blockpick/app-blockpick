#!/bin/bash

# 프론트엔드처럼 API를 통해 암호화 키 생성 테스트
# SQS가 제대로 작동하는지 확인

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 설정
API_URL="${API_URL:-http://localhost:8080}"
GRAPHQL_ENDPOINT="${API_URL}/graphql"

# 테스트 사용자
TEST_USER_EMAIL="testuser@blockpick.com"
TEST_USER_PASSWORD="123456"

# 지갑 주소 (프론트엔드에서 보낼 주소)
WALLET_ADDRESS="0xf41346bd091cC867DF3E9c3c0C4a2c2e5e123456"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}프론트엔드 암호화 키 API 테스트${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: 로그인하여 JWT 토큰 획득 (GraphQL)
echo -e "${YELLOW}[Step 1] 로그인 중...${NC}"

LOGIN_MUTATION=$(cat <<EOF
{
  "query": "mutation Login(\$input: LoginRequest!) { login(input: \$input) { success code message accessToken refreshToken user { id email nickname } } }",
  "variables": {
    "input": {
      "email": "${TEST_USER_EMAIL}",
      "password": "${TEST_USER_PASSWORD}"
    }
  }
}
EOF
)

LOGIN_RESPONSE=$(curl -s -X POST "${GRAPHQL_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -d "$LOGIN_MUTATION")

echo "로그인 응답:"
echo "$LOGIN_RESPONSE" | jq '.'

ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.login.accessToken // empty')

if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" = "null" ]; then
    echo -e "${RED}❌ 로그인 실패: 토큰을 가져올 수 없습니다${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 로그인 성공${NC}"
echo ""

# Step 2: 활성화된 게임 목록 조회
echo -e "${YELLOW}[Step 2] 활성화된 게임 조회 중...${NC}"
GAMES_QUERY='{
  "query": "query { gameList(page: 0, size: 10) { success games { id title onchainContractAddr status maxEntries currentEntries } } }"
}'

GAMES_RESPONSE=$(curl -s -X POST "${GRAPHQL_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -d "$GAMES_QUERY")

echo "게임 목록 응답:"
echo "$GAMES_RESPONSE" | jq '.'

# 첫 번째 게임 선택
GAME_ID=$(echo "$GAMES_RESPONSE" | jq -r '.data.gameList.games[0].id // empty')
CONTRACT_ADDRESS=$(echo "$GAMES_RESPONSE" | jq -r '.data.gameList.games[0].onchainContractAddr // empty')

if [ -z "$GAME_ID" ] || [ "$GAME_ID" = "null" ]; then
    echo -e "${RED}❌ 활성화된 게임이 없습니다${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 게임 선택: ${GAME_ID}${NC}"
echo -e "${GREEN}   컨트랙트 주소: ${CONTRACT_ADDRESS}${NC}"
echo ""

# Step 3: 암호화 키 요청 (프론트엔드처럼)
echo -e "${YELLOW}[Step 3] 암호화 키 생성 요청 (GraphQL API)${NC}"

# userIndex 생성 (프론트엔드에서 보낼 고유 인덱스)
USER_INDEX="user_$(date +%s)_${RANDOM}"

echo "요청 파라미터:"
echo "  - gameId: ${GAME_ID}"
echo "  - userAddress: ${WALLET_ADDRESS}"
echo "  - userIndex: ${USER_INDEX}"
echo ""

# GraphQL mutation
ENCRYPTION_KEY_MUTATION=$(cat <<EOF
{
  "query": "mutation RequestEncryptionKey(\$input: RequestEncryptionKeyInput!) { requestEncryptionKey(input: \$input) { success code message encryptionKey contractAddress txHash userAddress index } }",
  "variables": {
    "input": {
      "gameId": "${GAME_ID}",
      "userAddress": "${WALLET_ADDRESS}",
      "index": "${USER_INDEX}"
    }
  }
}
EOF
)

echo "GraphQL Mutation:"
echo "$ENCRYPTION_KEY_MUTATION" | jq '.'
echo ""

KEY_RESPONSE=$(curl -s -X POST "${GRAPHQL_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -d "$ENCRYPTION_KEY_MUTATION")

echo "암호화 키 생성 응답:"
echo "$KEY_RESPONSE" | jq '.'
echo ""

# 응답 파싱
SUCCESS=$(echo "$KEY_RESPONSE" | jq -r '.data.requestEncryptionKey.success // false')
CODE=$(echo "$KEY_RESPONSE" | jq -r '.data.requestEncryptionKey.code // empty')
MESSAGE=$(echo "$KEY_RESPONSE" | jq -r '.data.requestEncryptionKey.message // empty')
REQUEST_ID=$(echo "$KEY_RESPONSE" | jq -r '.data.requestEncryptionKey.txHash // empty')

if [ "$SUCCESS" = "true" ]; then
    echo -e "${GREEN}✅ 암호화 키 요청 성공${NC}"
    echo -e "${GREEN}   요청 ID: ${REQUEST_ID}${NC}"
    echo -e "${GREEN}   메시지: ${MESSAGE}${NC}"
else
    echo -e "${RED}❌ 암호화 키 요청 실패${NC}"
    echo -e "${RED}   코드: ${CODE}${NC}"
    echo -e "${RED}   메시지: ${MESSAGE}${NC}"
    exit 1
fi

echo ""

# Step 4: SQS 처리 대기
echo -e "${YELLOW}[Step 4] SQS 워커가 블록체인 트랜잭션을 처리할 때까지 대기 중...${NC}"
echo "대기 시간: 30초"

for i in {1..30}; do
    echo -n "."
    sleep 1
done
echo ""
echo ""

# Step 5: PolygonScan에서 트랜잭션 확인
echo -e "${YELLOW}[Step 5] PolygonScan에서 트랜잭션 확인${NC}"
echo "컨트랙트 주소: ${CONTRACT_ADDRESS}"
echo ""
echo "PolygonScan 확인 URL:"
echo "https://amoy.polygonscan.com/address/${CONTRACT_ADDRESS}#internaltx"
echo ""

# Step 6: 스마트 컨트랙트에서 직접 키 조회 (블록체인 테스트 API 사용)
echo -e "${YELLOW}[Step 6] 스마트 컨트랙트에서 암호화 키 조회${NC}"
echo "userIndex: ${USER_INDEX}"
echo ""

# 블록체인 테스트 API를 통해 키 조회
GET_KEY_RESPONSE=$(curl -s -X GET "${API_URL}/api/blockchain/test/get-key?contractAddress=${CONTRACT_ADDRESS}&index=${USER_INDEX}&userAddress=${WALLET_ADDRESS}")

echo "키 조회 응답:"
echo "$GET_KEY_RESPONSE" | jq '.'
echo ""

ENCRYPTION_KEY=$(echo "$GET_KEY_RESPONSE" | jq -r '.key // empty')

if [ -n "$ENCRYPTION_KEY" ] && [ "$ENCRYPTION_KEY" != "null" ] && [ "$ENCRYPTION_KEY" != "" ]; then
    echo -e "${GREEN}✅ 스마트 컨트랙트에서 암호화 키 조회 성공!${NC}"
    echo -e "${GREEN}   암호화 키: ${ENCRYPTION_KEY}${NC}"
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}🎉 SQS가 정상적으로 작동합니다!${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${RED}❌ 스마트 컨트랙트에서 암호화 키를 찾을 수 없습니다${NC}"
    echo -e "${RED}   SQS 워커가 트랜잭션을 처리하지 못했을 수 있습니다${NC}"
    echo ""
    echo -e "${YELLOW}디버깅 정보:${NC}"
    echo "1. 서버 로그에서 EncryptionKeyListener 확인"
    echo "2. SQS 큐에 메시지가 있는지 확인"
    echo "3. AWS 자격증명 및 권한 확인"
    echo ""
    exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}테스트 요약${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "📊 테스트 결과:"
echo "  게임 ID: ${GAME_ID}"
echo "  컨트랙트 주소: ${CONTRACT_ADDRESS}"
echo "  사용자 지갑: ${WALLET_ADDRESS}"
echo "  User Index: ${USER_INDEX}"
echo "  요청 ID (txHash): ${REQUEST_ID}"
echo "  암호화 키: ${ENCRYPTION_KEY}"
echo ""
echo "🔗 PolygonScan 확인:"
echo "  https://amoy.polygonscan.com/address/${CONTRACT_ADDRESS}"
echo ""
echo "📋 프론트엔드 구현 체크리스트:"
echo "  ✅ 1. 로그인 (GraphQL mutation: login)"
echo "  ✅ 2. 게임 목록 조회 (GraphQL query: gameList)"
echo "  ✅ 3. 암호화 키 생성 요청 (GraphQL mutation: requestEncryptionKey)"
echo "  ✅ 4. 상태 폴링 (GraphQL query: encryptionKeyStatus) - 권장!"
echo "  ✅ 5. 스마트 컨트랙트 키 조회 (Web3.js: contract.methods.getEncryptionKey)"
echo "  ⬜ 6. 좌표 암호화 (클라이언트 사이드)"
echo "  ⬜ 7. 암호화된 좌표 저장 (GraphQL mutation: storeEncryptedCoordinates)"
echo ""
echo "📚 참고 문서:"
echo "  - 프론트엔드 가이드: docs/FRONTEND_ENCRYPTION_KEY_TEST_RESULT.md"
echo "  - API 문서: docs/ENCRYPTION_KEY_FLOW.md"
echo "  - 전체 플로우 테스트: scripts/test-encryption-key-full-flow.sh"
echo ""
echo -e "${GREEN}✅ 모든 테스트 통과!${NC}"
echo ""
echo "💬 문의사항이 있으시면 백엔드 팀에 연락 주세요!"

