import 'package:flutter/material.dart';

class ChecklistCheckboxWidget extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final int? flex;

  const ChecklistCheckboxWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.flex,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Flexible(
      flex: flex ?? 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: value ? scheme.primary : Colors.grey.shade300,
            width: value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: value ? scheme.primaryContainer.withOpacity(0.2) : Colors.transparent,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(!value),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: value,
                    onChanged: (v) => onChanged(v ?? false),
                    activeColor: scheme.primary,
                  ),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
