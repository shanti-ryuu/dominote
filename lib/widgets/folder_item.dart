import 'package:flutter/material.dart';
import '../models/folder.dart';

class FolderItem extends StatelessWidget {
  final Folder folder;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const FolderItem({
    super.key,
    required this.folder,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(
        Icons.folder,
        color: isSelected
            ? theme.colorScheme.primary
            : isDarkMode ? Colors.grey[400] : Colors.grey[700],
      ),
      title: Text(
        folder.name,
        style: TextStyle(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.edit,
              size: 20,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              size: 20,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onTap,
      selected: isSelected,
      tileColor: isSelected
          ? (isDarkMode ? Colors.grey[800] : Colors.grey[200])
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
