🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:37.671
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 21/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:39.674
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:39.860
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 22/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:41.863
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:42.053
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 23/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:44.056
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:44.248
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 24/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:46.250
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:46.442
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 25/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:48.449
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:48.637
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 26/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:50.640
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:50.831
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 27/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:52.838
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:53.028
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 GameGridWidget.didUpdateWidget():
js_primitives.dart:28    - old backgroundImagePath: https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg
js_primitives.dart:28    - new backgroundImagePath: https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg
js_primitives.dart:28    ℹ️ 배경 이미지 변경 없음
js_primitives.dart:28 📌 선택된 블록 1개:
js_primitives.dart:28    - 500-500: row=500, col=500
js_primitives.dart:28 🔄 GameGridWidget.didUpdateWidget():
js_primitives.dart:28    - old backgroundImagePath: https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg
js_primitives.dart:28    - new backgroundImagePath: https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg
js_primitives.dart:28    ℹ️ 배경 이미지 변경 없음
js_primitives.dart:28 📌 선택된 블록 1개:
js_primitives.dart:28    - 500-500: row=500, col=500
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 28/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:55.064
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:55.265
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 29/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:57.269
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:57.471
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 30/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:59.474
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:07:59.679
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 31/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:01.682
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:01.966
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 32/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:03.969
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:04.162
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 33/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:06.167
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:06.362
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 34/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:08.366
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:08.634
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 35/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:10.638
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:10.832
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 36/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:12.835
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:13.038
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 37/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:15.045
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:15.233
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 38/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:17.235
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:17.423
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 39/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:19.426
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:19.620
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 40/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:21.622
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:21.811
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 41/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:23.814
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:24.009
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 42/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:26.012
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:26.209
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 43/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:28.212
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:28.406
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 44/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:30.410
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:30.597
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 45/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:32.601
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:32.790
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 46/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:34.793
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:35.046
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 47/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:37.049
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:37.240
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 48/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:39.242
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:39.430
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 GameGridWidget.didUpdateWidget():
js_primitives.dart:28    - old backgroundImagePath: https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg
js_primitives.dart:28    - new backgroundImagePath: https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg
js_primitives.dart:28    ℹ️ 배경 이미지 변경 없음
js_primitives.dart:28 📌 선택된 블록 1개:
js_primitives.dart:28    - 500-500: row=500, col=500
js_primitives.dart:28 🔄 GameGridWidget.didUpdateWidget():
js_primitives.dart:28    - old backgroundImagePath: https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg
js_primitives.dart:28    - new backgroundImagePath: https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg
js_primitives.dart:28    ℹ️ 배경 이미지 변경 없음
js_primitives.dart:28 📌 선택된 블록 1개:
js_primitives.dart:28    - 500-500: row=500, col=500
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 49/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:41.434
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:41.623
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 50/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:43.625
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:43.816
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 51/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:45.818
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:46.005
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 52/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:48.008
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:48.199
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 53/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:50.206
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:50.393
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 54/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:52.396
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:52.592
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 55/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:54.594
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:54.782
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 56/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:56.785
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:56.975
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 57/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:58.983
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:08:59.170
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 58/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:09:01.172
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:09:01.383
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 59/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:09:03.386
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:09:03.572
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 🔄 [암호화 키 폴링] 시도 60/60 (requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc)
js_primitives.dart:28 📤 GraphQL 요청:
js_primitives.dart:28    - Operation: unnamed
js_primitives.dart:28    - Variables: {requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc}
js_primitives.dart:28 📤 DioHttpClient 요청:
js_primitives.dart:28    - URL: https://api-dev.blockpick.net/graphql
js_primitives.dart:28    - Method: POST
js_primitives.dart:28    - Headers: {content-type: application/json, Accept: */*}
js_primitives.dart:28    - Timestamp: 2025-12-12T09:09:05.575
js_primitives.dart:28    - Body: {"operationName":null,"variables":{"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc"},"query":"query EncryptionKeyStatus($requestId: String!) {\n  encryptionKeyStatus(requestId: $requestId) {\n    success\n    requestId\n    status\n    txHash\n    errorCode\n    errorMessage\n  }\n}"}
js_primitives.dart:28 🔑 Authorization 헤더 추가
adapter_impl.dart:54 Refused to set unsafe header "Accept-Encoding"
(anonymous) @ adapter_impl.dart:54
forEach @ linked_hash_map.dart:21
(anonymous) @ adapter_impl.dart:50
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
_asyncStartSync @ async_patch.dart:542
fetch @ adapter_impl.dart:31
(anonymous) @ dio_mixin.dart:532
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
complete @ async_patch.dart:504
_asyncReturn @ async_patch.dart:571
(anonymous) @ dio_mixin.dart:687
(anonymous) @ async_patch.dart:623
(anonymous) @ async_patch.dart:648
(anonymous) @ async_patch.dart:594
runUnary @ zone.dart:1849
handleValue @ future_impl.dart:222
handleValueCallback @ future_impl.dart:948
_propagateToListeners @ future_impl.dart:977
[_completeWithValue] @ future_impl.dart:720
(anonymous) @ future_impl.dart:804
_microtaskLoop @ schedule_microtask.dart:40
_startMicrotaskLoop @ schedule_microtask.dart:49
tear @ operations.dart:118
(anonymous) @ async_patch.dart:188Understand this error
js_primitives.dart:28 ✅ Dio 응답 성공: 200
js_primitives.dart:28 📥 DioHttpClient 응답:
js_primitives.dart:28    - Status: 200
js_primitives.dart:28    - Timestamp: 2025-12-12T09:09:05.771
js_primitives.dart:28    - Headers: {cache-control: [no-cache, no-store, max-age=0, must-revalidate], content-length: [169], content-type: [application/json], expires: [0], pragma: [no-cache]}
js_primitives.dart:28    - Data length: 169
js_primitives.dart:28    - Data: {"data":{"encryptionKeyStatus":{"success":true,"requestId":"642dbae9-82bf-4d04-a411-bf563ca6dacc","status":"QUEUED","txHash":null,"errorCode":null,"errorMessage":null}}}
js_primitives.dart:28 📥 GraphQL 응답:
js_primitives.dart:28    - Data: {encryptionKeyStatus: {success: true, requestId: 642dbae9-82bf-4d04-a411-bf563ca6dacc, status: QUEUED, txHash: null, errorCode: null, errorMessage: null}}
js_primitives.dart:28    - Errors: null
js_primitives.dart:28 📊 [암호화 키 폴링] 상태: QUEUED
js_primitives.dart:28 │ 🔄 상태: QUEUED
js_primitives.dart:28 ⏱️  [암호화 키 폴링] 타임아웃 (최대 시도 횟수 초과)
js_primitives.dart:28 │ ❌ encryptionKeyStatus 폴링 실패: TimeoutException: 암호화 키 생성 타임아웃 (120초)
js_primitives.dart:28 │
js_primitives.dart:28 │ ⚠️  SQS 워커 문제 가능성:
js_primitives.dart:28 │    1. SQS 워커가 작동하지 않음
js_primitives.dart:28 │    2. 서버 지갑에 가스비(POL)가 부족
js_primitives.dart:28 │    3. 네트워크 문제
js_primitives.dart:28 └─────────────────────────────────────────────────────────────────────────────┘
js_primitives.dart:28
js_primitives.dart:28 ╔═══════════════════════════════════════════════════════════════════════════╗
js_primitives.dart:28 ║  ❌ 게임 참여 프로세스 실패                                                 ║
js_primitives.dart:28 ╚═══════════════════════════════════════════════════════════════════════════╝
js_primitives.dart:28
js_primitives.dart:28 🔍 에러 상세:
js_primitives.dart:28    Exception: 암호화 키 생성 실패: TimeoutException: 암호화 키 생성 타임아웃 (120초)
js_primitives.dart:28
js_primitives.dart:28 📚 Stack Trace (처음 10줄):
js_primitives.dart:28    dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 274:3       throw_
js_primitives.dart:28    package:blockpick_flutter/providers/game_participation_provider.dart 397:13       <fn>
js_primitives.dart:28    dart-sdk/lib/_internal/js_dev_runtime/patch/async_patch.dart 623:19               <fn>
js_primitives.dart:28    dart-sdk/lib/_internal/js_dev_runtime/patch/async_patch.dart 648:23               <fn>
js_primitives.dart:28    dart-sdk/lib/_internal/js_dev_runtime/patch/async_patch.dart 594:19               <fn>
js_primitives.dart:28    dart-sdk/lib/async/zone.dart 1849:54                                              runUnary
js_primitives.dart:28    dart-sdk/lib/async/future_impl.dart 222:18                                        handleValue
js_primitives.dart:28    dart-sdk/lib/async/future_impl.dart 948:44                                        handleValueCallback
js_primitives.dart:28    dart-sdk/lib/async/future_impl.dart 977:13                                        _propagateToListeners
js_primitives.dart:28    dart-sdk/lib/async/future_impl.dart 543:9                                         <fn>
js_primitives.dart:28
js_primitives.dart:28 ❌ 게임 참가 에러: Exception: 암호화 키 생성 실패: TimeoutException: 암호화 키 생성 타임아웃 (120초)
js_primitives.dart:28 🔄 GameGridWidget.didUpdateWidget():
js_primitives.dart:28    - old backgroundImagePath: https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg
js_primitives.dart:28    - new backgroundImagePath: https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg
js_primitives.dart:28    ℹ️ 배경 이미지 변경 없음
js_primitives.dart:28 📌 선택된 블록 1개:
js_primitives.dart:28    - 500-500: row=500, col=500
js_primitives.dart:28 🔄 GameGridWidget.didUpdateWidget():
js_primitives.dart:28    - old backgroundImagePath: https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg
js_primitives.dart:28    - new backgroundImagePath: https://blockpick-dev-storage.s3.us-west-2.amazonaws.com/products/2025/10/27/8e758de6_iPad Pro_1500.jpg
js_primitives.dart:28    ℹ️ 배경 이미지 변경 없음
js_primitives.dart:28 📌 선택된 블록 1개:
js_primitives.dart:28 
