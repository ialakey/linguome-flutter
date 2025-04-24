import 'package:flutter/material.dart';
import 'package:linguome/config/app_config.dart';
import 'package:linguome/helper/amplitude_manager.dart';
import 'package:linguome/localizations/app_localizations.dart';

class SearchCustomBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String, String?, String?) filterList;

  const SearchCustomBar({
    required this.controller,
    required this.filterList,
  });

  @override
  _SearchCustomBarState createState() => _SearchCustomBarState();
}

class _SearchCustomBarState extends State<SearchCustomBar> {
  String? _selectedSort = 'abc';
  List<String?> _selectedStatus = [];

  void _onStatusChanged(String status, bool selected) {
    setState(() {
      if (selected) {
        _selectedStatus.add(status);
      } else {
        _selectedStatus.remove(status);
      }
    });

    String? selectedStatusString = _selectedStatus.isNotEmpty ? _selectedStatus.join(',') : null;

    if (_selectedStatus.contains('new')) {
      widget.filterList(widget.controller.text, null, null);
    } else {
      widget.filterList(widget.controller.text, _selectedSort, selectedStatusString);
    }
  }

  bool _isStatusSelected(String status) {
    return _selectedStatus.contains(status);
  }

  void _openFilterModal() {
    AmplitudeManager().logProfileEvent(
      'SearchCustomBar',
      eventProperties: {
        'button_clicked': 'filter',
      },
    );
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.background,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void _toggleSortOrderInModal() {
              setModalState(() {
                _selectedSort = _selectedSort == 'abc' ? '-abc' : 'abc';
              });
              widget.filterList(widget.controller.text, _selectedSort, null);
            }

            void _resetFiltersInModal() {
              setModalState(() {
                _selectedStatus.clear();
              });
              widget.filterList(widget.controller.text, null, null);
              Navigator.pop(context);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.translate('sortAlphabetically'),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            IconButton(
                              icon: _selectedSort == 'abc'
                                  ? Icon(Icons.sort_by_alpha)
                                  : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(3.14159),
                                child: Icon(Icons.sort_by_alpha),
                              ),
                              onPressed: _toggleSortOrderInModal,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.translate('status'),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                        Column(
                          children: [
                            CheckboxListTile(
                              activeColor: Colors.blueAccent,
                              value: _isStatusSelected('new'),
                              title: Text(
                                AppLocalizations.of(context)!.translate('new'),
                                style: TextStyle(fontFamily: 'Inter'),
                              ),
                              onChanged: (selected) {
                                setModalState(() {
                                  _onStatusChanged('new', selected!);
                                });
                              },
                            ),
                            CheckboxListTile(
                              activeColor: Colors.blueAccent,
                              value: _isStatusSelected('on-study'),
                              title: Text(
                                AppLocalizations.of(context)!.translate('onStudy'),
                                style: TextStyle(fontFamily: 'Inter'),
                              ),
                              onChanged: (selected) {
                                setModalState(() {
                                  _onStatusChanged('on-study', selected!);
                                });
                              },
                            ),
                            CheckboxListTile(
                              activeColor: Colors.blueAccent,
                              value: _isStatusSelected('known'),
                              title: Text(
                                AppLocalizations.of(context)!.translate('know'),
                                style: TextStyle(fontFamily: 'Inter'),
                              ),
                              onChanged: (selected) {
                                setModalState(() {
                                  _onStatusChanged('known', selected!);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.background,
                      onPrimary: Colors.black,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                    onPressed: _resetFiltersInModal,
                    child: Text(
                      AppLocalizations.of(context)!.translate('reset'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(width: 20),
          Image.asset('${AppConfig.assetsIcons}search.png', width: 20, height: 20),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: (value) => widget.filterList(value, _selectedSort, null),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.translate('searchWithDots'),
                // border: InputBorder.none,
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(26.0)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    widget.filterList('', _selectedSort, null);
                  },
                )
                    : null,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _openFilterModal,
          ),
        ],
      ),
    );
  }
}