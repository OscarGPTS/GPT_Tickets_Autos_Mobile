import 'package:flutter/material.dart';

class FormToggleWidget extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  const FormToggleWidget({
    super.key,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
    this.icon,
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
        borderRadius: BorderRadius.circular(12),
        color: value ? scheme.primaryContainer.withOpacity(0.3) : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 24,
                    color: value ? scheme.primary : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: scheme.primary,
                  activeTrackColor: scheme.primary.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
