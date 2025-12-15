import 'package:flutter/material.dart';

class ChecklistCheckboxWidget extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final int? flex;

  const ChecklistCheckboxWidget({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.flex,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
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
          onTap: onChanged != null ? () => onChanged?.call(!value) : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: value,
                    onChanged: onChanged != null ? (v) => onChanged?.call(v ?? false) : null,
                    activeColor: scheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                      color: Colors.grey.shade800,
                      height: 1.1,
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
    );
  }

}
