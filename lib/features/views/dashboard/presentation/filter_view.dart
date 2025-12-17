import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:streaming_dashboard/core/constants/app_strings.dart';
import 'package:streaming_dashboard/core/theme/app_themes.dart';
import 'package:streaming_dashboard/features/views/dashboard/data_model/filter_view_model.dart';

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  late FilterViewModel _filterVM;

  @override
  void initState() {
    super.initState();
    _filterVM = FilterViewModel();
    _filterVM.fetchAllDivisionList(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final maxWidth = isTablet ? 600.0 : double.infinity;
    final fieldHeight = isTablet ? 45.0 : 40.0;
    final fontSize = isTablet ? 17.0 : 14.0;
    final labelFontSize = isTablet ? 16.0 : 14.0;

    // ✅ Get theme mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppThemes.getBackgroundColor(context),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider<FilterViewModel>(
            create: (context) => _filterVM,
          ),
        ],
        child: Consumer<FilterViewModel>(
          builder: (context, filterVM, child) {
            return SafeArea(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 32 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            AppStrings.ksApplyFilter,
                            style: TextStyle(
                              fontSize: isTablet ? 32 : 24,
                              fontWeight: FontWeight.w600,
                              color: AppThemes.getTextColor(context),
                            ),
                          ),
                          SizedBox(height: isTablet ? 32 : 24),

                          // Search Field
                          _buildSearchField(isDarkMode),
                          SizedBox(height: isTablet ? 24 : 16),

                          // Division Dropdown
                          _buildDropdown(
                            label: AppStrings.ksSelectDivision,
                            required: true,
                            value: filterVM.selectedDivisionId,
                            items: filterVM.allDivisionListArray,
                            hint: AppStrings.ksSelectDivision,
                            fullObjects: filterVM.allDivisionList,
                            idField: 'division',
                            nameField: 'divisionName',
                            onChanged: (displayValue, id) async {
                              setState(() {
                                filterVM.selectedDivision = displayValue;
                                filterVM.selectedDivisionId = id;
                              });
                              await filterVM.divisionBasedDistrictAPI(
                                context,
                                filterVM.selectedDivisionId,
                              );
                            },
                            height: fieldHeight,
                            fontSize: fontSize,
                            labelFontSize: labelFontSize,
                            isDarkMode: isDarkMode,
                          ),
                          SizedBox(height: isTablet ? 20 : 12),

                          // District Dropdown
                          _buildDropdown(
                            label: AppStrings.ksSelectDistrict,
                            required: true,
                            value: filterVM.selectedDistrictId,
                            items: filterVM.allDistrictListArray,
                            hint: AppStrings.ksSelectDistrict,
                            fullObjects: filterVM.allDistrictList,
                            idField: 'district',
                            nameField: 'districtName',
                            onChanged: (displayValue, id) async {
                              setState(() {
                                filterVM.selectedDistrict = displayValue;
                                filterVM.selectedDistrictId = id;
                              });
                              await filterVM.divisionDistrictBasedWorkTypeAPI(
                                context,
                                filterVM.selectedDivisionId,
                                filterVM.selectedDistrictId,
                              );
                            },
                            height: fieldHeight,
                            fontSize: fontSize,
                            labelFontSize: labelFontSize,
                            isDarkMode: isDarkMode,
                          ),
                          SizedBox(height: isTablet ? 20 : 12),

                          // Work Type Dropdown
                          _buildDropdown(
                            label: AppStrings.ksSelectMainCategory,
                            required: true,
                            value: filterVM.selectedWorkType,
                            items: filterVM.allWorkListArray,
                            hint: AppStrings.ksSelectMainCategory,
                            fullObjects: filterVM.allWorkTypeList,
                            idField: '',
                            nameField: 'mainCategory',
                            onChanged: (displayValue, id) async {
                              setState(() {
                                filterVM.selectedWorkType = displayValue;
                              });
                              await filterVM.subWorkTypeAPI(
                                context,
                                filterVM.selectedDivisionId,
                                filterVM.selectedDistrictId,
                                filterVM.selectedWorkType,
                              );
                            },
                            height: fieldHeight,
                            fontSize: fontSize,
                            labelFontSize: labelFontSize,
                            isDarkMode: isDarkMode,
                          ),
                          SizedBox(height: isTablet ? 20 : 12),

                          // Sub-Type Dropdown
                          _buildDropdown(
                            label: AppStrings.ksSelectSubWorkType,
                            required: true,
                            value: filterVM.selectedSubWorkType,
                            items: filterVM.allSubWorkListArray,
                            hint: AppStrings.ksSelectSubWorkType,
                            fullObjects: filterVM.allSubWorkTypeList,
                            idField: '',
                            nameField: 'subcategory',
                            onChanged: (displayValue, id) async {
                              setState(() {
                                filterVM.selectedSubWorkType = displayValue;
                              });
                              await filterVM.workStatusAPI(
                                context,
                                filterVM.selectedDivisionId,
                                filterVM.selectedDistrictId,
                                filterVM.selectedWorkType,
                                filterVM.selectedSubWorkType,
                              );
                            },
                            height: fieldHeight,
                            fontSize: fontSize,
                            labelFontSize: labelFontSize,
                            isDarkMode: isDarkMode,
                          ),
                          SizedBox(height: isTablet ? 20 : 12),

                          // Work Status Dropdown
                          _buildDropdown(
                            label: AppStrings.ksSelectWorkStatus,
                            required: true,
                            value: filterVM.selectedWorkStatus,
                            items: filterVM.allWorkStatusListArray,
                            hint: AppStrings.ksSelectWorkStatus,
                            fullObjects: filterVM.allWorkStatusList,
                            idField: '',
                            nameField: 'mainCategory',
                            onChanged: (displayValue, id) async {
                              setState(() {
                                filterVM.selectedWorkStatus = displayValue;
                              });
                              await filterVM.tenderNumberAPI(
                                context,
                                filterVM.selectedDivisionId,
                                filterVM.selectedDistrictId,
                                filterVM.selectedWorkType,
                                filterVM.selectedSubWorkType,
                                filterVM.selectedWorkStatus,
                              );
                            },
                            height: fieldHeight,
                            fontSize: fontSize,
                            labelFontSize: labelFontSize,
                            isDarkMode: isDarkMode,
                          ),
                          SizedBox(height: isTablet ? 20 : 12),

                          // Tender Number Dropdown
                          _buildDropdown(
                            label: AppStrings.ksTenderNumber,
                            required: true,
                            value: filterVM.selectedTenderNumberId,
                            items: filterVM.allTenderNumberListArray,
                            hint: AppStrings.ksTenderNumber,
                            fullObjects: filterVM.allTenderNumberList,
                            idField: 'tenderId',
                            nameField: 'tenderNumber',
                            onChanged: (displayValue, id) async {
                              setState(() {
                                filterVM.selectedTenderNumber = displayValue;
                                filterVM.selectedTenderNumberId = id;
                              });
                            },
                            height: fieldHeight,
                            fontSize: fontSize,
                            labelFontSize: labelFontSize,
                            isDarkMode: isDarkMode,
                          ),
                          SizedBox(height: isTablet ? 20 : 30),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildButton(
                                  text: AppStrings.ksBack,
                                  isPrimary: false,
                                  onPressed: () {
                                    context.pop();
                                  },
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                              SizedBox(width: isTablet ? 20 : 16),
                              Expanded(
                                child: _buildButton(
                                  text: AppStrings.ksOk,
                                  isPrimary: true,
                                  onPressed: () {
                                    final filterParams = {
                                      'divisionId': filterVM.selectedDivisionId,
                                      'districtId': filterVM.selectedDistrictId,
                                      'mainCategory': filterVM.selectedWorkType,
                                      'subCategory':
                                          filterVM.selectedSubWorkType,
                                      'workStatus': filterVM.selectedWorkStatus,
                                      'tenderId':
                                          filterVM.selectedTenderNumberId,
                                      'workId': filterVM.searchController.text,
                                    };
                                    context.pop(filterParams);
                                  },
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isDarkMode) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2a2a2a) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(isTablet ? 32 : 28),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _filterVM.searchController,
        style: TextStyle(color: AppThemes.getTextColor(context)),
        decoration: InputDecoration(
          hintText: AppStrings.ksEnterWorkId,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: isTablet ? 18 : 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            size: isTablet ? 28 : 24,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 20,
            vertical: isTablet ? 20 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required bool required,
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String? displayValue, String? id) onChanged,
    required double height,
    required double fontSize,
    required double labelFontSize,
    required List<dynamic>? fullObjects,
    required String idField,
    required String nameField,
    required bool isDarkMode,
  }) {
    final bool hasIdField = idField.isNotEmpty;

    // Safety check: Ensure value exists in items
    String? safeValue = value;
    if (hasIdField && fullObjects != null) {
      final exists = fullObjects.any((obj) {
        final json = obj.toJson();
        return json[idField]?.toString() == value;
      });
      if (!exists) {
        safeValue = null;
      }
    } else {
      if (value != null && !items.contains(value)) {
        safeValue = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppThemes.getTextColor(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: labelFontSize),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2a2a2a) : Colors.grey.shade100,
            border: Border.all(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              hint: Text(
                hint,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: fontSize,
                ),
              ),
              value: safeValue,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 20,
              ),
              dropdownColor: isDarkMode
                  ? const Color(0xFF2a2a2a)
                  : Colors.white,
              style: TextStyle(
                fontSize: fontSize,
                color: AppThemes.getTextColor(context),
              ),
              items: hasIdField
                  ? fullObjects?.map((obj) {
                          final json = obj.toJson();
                          final id = json[idField]?.toString() ?? '';
                          final displayName = json[nameField]?.toString() ?? '';
                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text(displayName),
                          );
                        }).toList() ??
                        []
                  : items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
              onChanged: (selectedValue) {
                if (selectedValue == null) return;

                if (hasIdField) {
                  if (fullObjects != null) {
                    try {
                      final selectedObj = fullObjects.firstWhere((element) {
                        final json = element.toJson();
                        return json[idField]?.toString() == selectedValue;
                      });
                      final json = selectedObj.toJson();
                      final displayName = json[nameField]?.toString();
                      onChanged(displayName, selectedValue);
                    } catch (e) {
                      print('Error finding object: $e');
                      onChanged(selectedValue, selectedValue);
                    }
                  }
                } else {
                  onChanged(selectedValue, selectedValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
    required bool isDarkMode,
  }) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? const Color(0xFF0066FF)
            : (isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade300),
        foregroundColor: isPrimary
            ? Colors.white
            : (isDarkMode ? Colors.white : Colors.black87),
        padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isTablet ? 20 : 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _filterVM.searchController.dispose();
    super.dispose();
  }
}
