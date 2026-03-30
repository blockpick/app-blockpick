import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// 국가 정보 모델
class _CountryInfo {
  final String name;
  final String code;
  final String dialCode;

  const _CountryInfo({
    required this.name,
    required this.code,
    required this.dialCode,
  });

  String get displayDialCode => '+$dialCode';
}

/// 주요 국가 목록
const _countries = <_CountryInfo>[
  _CountryInfo(name: 'Korea, Republic of', code: 'KR', dialCode: '82'),
  _CountryInfo(name: 'United States', code: 'US', dialCode: '1'),
  _CountryInfo(name: 'Japan', code: 'JP', dialCode: '81'),
  _CountryInfo(name: 'China', code: 'CN', dialCode: '86'),
  _CountryInfo(name: 'Taiwan', code: 'TW', dialCode: '886'),
  _CountryInfo(name: 'Hong Kong', code: 'HK', dialCode: '852'),
  _CountryInfo(name: 'Singapore', code: 'SG', dialCode: '65'),
  _CountryInfo(name: 'Thailand', code: 'TH', dialCode: '66'),
  _CountryInfo(name: 'Vietnam', code: 'VN', dialCode: '84'),
  _CountryInfo(name: 'Philippines', code: 'PH', dialCode: '63'),
  _CountryInfo(name: 'Indonesia', code: 'ID', dialCode: '62'),
  _CountryInfo(name: 'Malaysia', code: 'MY', dialCode: '60'),
  _CountryInfo(name: 'India', code: 'IN', dialCode: '91'),
  _CountryInfo(name: 'Australia', code: 'AU', dialCode: '61'),
  _CountryInfo(name: 'United Kingdom', code: 'GB', dialCode: '44'),
  _CountryInfo(name: 'Germany', code: 'DE', dialCode: '49'),
  _CountryInfo(name: 'France', code: 'FR', dialCode: '33'),
  _CountryInfo(name: 'Canada', code: 'CA', dialCode: '1'),
  _CountryInfo(name: 'Brazil', code: 'BR', dialCode: '55'),
  _CountryInfo(name: 'Mexico', code: 'MX', dialCode: '52'),
  _CountryInfo(name: 'Russia', code: 'RU', dialCode: '7'),
  _CountryInfo(name: 'Turkey', code: 'TR', dialCode: '90'),
  _CountryInfo(name: 'Saudi Arabia', code: 'SA', dialCode: '966'),
  _CountryInfo(name: 'United Arab Emirates', code: 'AE', dialCode: '971'),
  _CountryInfo(name: 'New Zealand', code: 'NZ', dialCode: '64'),
  _CountryInfo(name: 'Italy', code: 'IT', dialCode: '39'),
  _CountryInfo(name: 'Spain', code: 'ES', dialCode: '34'),
  _CountryInfo(name: 'Netherlands', code: 'NL', dialCode: '31'),
  _CountryInfo(name: 'Sweden', code: 'SE', dialCode: '46'),
  _CountryInfo(name: 'Switzerland', code: 'CH', dialCode: '41'),
];

/// SC-011-15: 상품받기 (배송지 입력) 화면
class ShippingAddressScreen extends ConsumerStatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  ConsumerState<ShippingAddressScreen> createState() =>
      _ShippingAddressScreenState();
}

class _ShippingAddressScreenState
    extends ConsumerState<ShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // 국가 선택
  _CountryInfo _selectedCountry = _countries.first; // Korea, Republic of

  // 텍스트 컨트롤러
  final _fullNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _customsIdController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();

  // 전화번호 국가코드
  late _CountryInfo _phone1Country;
  late _CountryInfo _phone2Country;

  // 제출 중 상태
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _phone1Country = _selectedCountry;
    _phone2Country = _selectedCountry;

    // 필수 필드 변경 시 버튼 활성화 갱신
    _fullNameController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _address1Controller.addListener(_onFieldChanged);
    _phone1Controller.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _customsIdController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {});
  }

  /// 필수 필드가 모두 입력되었는지 확인
  bool get _isFormValid {
    return _fullNameController.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty &&
        _address1Controller.text.trim().isNotEmpty &&
        _phone1Controller.text.trim().isNotEmpty;
  }

  /// 국가 선택 시 전화번호 국가코드도 자동 반영
  void _onCountryChanged(_CountryInfo country) {
    setState(() {
      _selectedCountry = country;
      _phone1Country = country;
      _phone2Country = country;
    });
  }

  /// 국가 검색 다이얼로그
  Future<_CountryInfo?> _showCountryPicker() async {
    return showModalBottomSheet<_CountryInfo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CountryPickerSheet(
        selectedCountry: _selectedCountry,
      ),
    );
  }

  /// 전화번호 국가코드 선택 다이얼로그
  Future<_CountryInfo?> _showDialCodePicker(_CountryInfo current) async {
    return showModalBottomSheet<_CountryInfo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CountryPickerSheet(
        selectedCountry: current,
        showDialCode: true,
      ),
    );
  }

  /// 배송지 등록 완료 처리
  Future<void> _submit() async {
    if (!_isFormValid || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    // TODO: GraphQL mutation 호출
    // try {
    //   await ref.read(someProvider.notifier).submitShippingAddress(
    //     country: _selectedCountry.code,
    //     fullName: _fullNameController.text.trim(),
    //     city: _cityController.text.trim(),
    //     state: _stateController.text.trim(),
    //     zipCode: _zipCodeController.text.trim(),
    //     address1: _address1Controller.text.trim(),
    //     address2: _address2Controller.text.trim(),
    //     customsId: _customsIdController.text.trim(),
    //     phone1Country: _phone1Country.dialCode,
    //     phone1: _phone1Controller.text.trim(),
    //     phone2Country: _phone2Country.dialCode,
    //     phone2: _phone2Controller.text.trim(),
    //   );
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('배송지 등록에 실패했습니다.')),
    //     );
    //   }
    //   setState(() => _isSubmitting = false);
    //   return;
    // }

    // 임시: 성공 처리
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('배송지 등록 완료! 소중한 경품이 곧 출발해요!'),
          backgroundColor: AppColors.darkBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      context.pop();
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text(
            '상품받기',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 안내 문구
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.gray50,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMd),
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: Text(
                          '당첨 상품 배송을 위해 배송지 정보를 입력해 주세요.\n정확한 정보를 입력해야 상품을 받으실 수 있습니다.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.gray600,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Country
                      _buildLabel('Country', required: true),
                      const SizedBox(height: 8),
                      _buildCountrySelector(),
                      const SizedBox(height: 20),

                      // Full name
                      _buildLabel('Full name', required: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _fullNameController,
                        hintText: '신분증상의 전체 실명',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // City
                      _buildLabel('City', required: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _cityController,
                        hintText: '도시명',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // State
                      _buildLabel('State'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _stateController,
                        hintText: '주/지역 명칭',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // ZIP / Postal Code
                      _buildLabel('ZIP / Postal Code'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _zipCodeController,
                        hintText: '우편번호',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Address 1
                      _buildLabel('Address 1', required: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _address1Controller,
                        hintText: '도로명 주소, P.O. box 등',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Address 2
                      _buildLabel('Address 2'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _address2Controller,
                        hintText: '아파트, 호수, 층 등',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Customs ID
                      _buildLabel('Customs ID'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _customsIdController,
                        hintText: '통관을 위한 식별 번호',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Phone Number 1
                      _buildLabel('Phone Number 1', required: true),
                      const SizedBox(height: 8),
                      _buildPhoneInput(
                        controller: _phone1Controller,
                        country: _phone1Country,
                        onCountryTap: () async {
                          final result =
                              await _showDialCodePicker(_phone1Country);
                          if (result != null) {
                            setState(() => _phone1Country = result);
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Phone Number 2
                      _buildLabel('Phone Number 2'),
                      const SizedBox(height: 8),
                      _buildPhoneInput(
                        controller: _phone2Controller,
                        country: _phone2Country,
                        onCountryTap: () async {
                          final result =
                              await _showDialCodePicker(_phone2Country);
                          if (result != null) {
                            setState(() => _phone2Country = result);
                          }
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // 완료 버튼
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// 필드 레이블 (필수 표시 포함)
  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
        ),
        if (required)
          Text(
            ' *',
            style: AppTextStyles.title3.copyWith(color: AppColors.red),
          ),
      ],
    );
  }

  /// 국가 선택 버튼
  Widget _buildCountrySelector() {
    return InkWell(
      onTap: () async {
        final result = await _showCountryPicker();
        if (result != null) {
          _onCountryChanged(result);
        }
      },
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedCountry.name,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }

  /// 일반 텍스트 입력 필드
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.darkBlue,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.gray400,
          fontSize: 16,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkBlue),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  /// 전화번호 입력 (국가코드 드롭다운 + TextField)
  Widget _buildPhoneInput({
    required TextEditingController controller,
    required _CountryInfo country,
    required VoidCallback onCountryTap,
  }) {
    return Row(
      children: [
        // 국가코드 드롭다운
        InkWell(
          onTap: onCountryTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  country.displayDialCode,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.gray500,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 전화번호 입력
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.darkBlue,
            ),
            decoration: InputDecoration(
              hintText: '숫자만 입력',
              hintStyle: TextStyle(
                color: AppColors.gray400,
                fontSize: 16,
              ),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                borderSide: const BorderSide(color: AppColors.darkBlue),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 완료 버튼 (하단 고정)
  Widget _buildSubmitButton() {
    final isEnabled = _isFormValid && !_isSubmitting;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isEnabled ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBlue,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.gray300,
              disabledForegroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    '완료',
                    style: AppTextStyles.title2,
                  ),
          ),
        ),
      ),
    );
  }
}

/// 국가 선택 바텀시트
class _CountryPickerSheet extends StatefulWidget {
  final _CountryInfo selectedCountry;
  final bool showDialCode;

  const _CountryPickerSheet({
    required this.selectedCountry,
    this.showDialCode = false,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchController = TextEditingController();
  List<_CountryInfo> _filteredCountries = _countries;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _countries;
      } else {
        final lower = query.toLowerCase();
        _filteredCountries = _countries.where((c) {
          return c.name.toLowerCase().contains(lower) ||
              c.code.toLowerCase().contains(lower) ||
              c.dialCode.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // 핸들
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 제목
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                widget.showDialCode ? '국가코드 선택' : '국가 선택',
                style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
              ),
            ),

            // 검색 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _filterCountries,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.darkBlue,
                ),
                decoration: InputDecoration(
                  hintText: '국가명 또는 코드 검색',
                  hintStyle: TextStyle(
                    color: AppColors.gray400,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.gray500,
                  ),
                  filled: true,
                  fillColor: AppColors.gray100,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // 국가 목록
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  final isSelected =
                      country.code == widget.selectedCountry.code;

                  return ListTile(
                    onTap: () => Navigator.of(context).pop(country),
                    title: Text(
                      widget.showDialCode
                          ? '${country.name} (${country.displayDialCode})'
                          : country.name,
                      style: TextStyle(
                        fontSize: 15,
                        color: isSelected
                            ? AppColors.blue
                            : AppColors.darkBlue,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.blue)
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
