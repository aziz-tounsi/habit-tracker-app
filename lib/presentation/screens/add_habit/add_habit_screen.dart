import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/suggestions.dart';
import '../../../data/models/habit_model.dart';
import '../../../providers/habit_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/glass_container.dart';

class AddHabitScreen extends StatefulWidget {
  final HabitModel? habitToEdit;

  const AddHabitScreen({super.key, this.habitToEdit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  String _selectedCategory = AppConstants.habitCategories[0];
  List<int> _selectedDays = [0, 1, 2, 3, 4]; // Mon-Fri by default
  int _targetDaysPerWeek = 5;
  TimeOfDay? _reminderTime;
  bool _isLoading = false;

  bool get isEditing => widget.habitToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.habitToEdit!.name;
      _descriptionController.text = widget.habitToEdit!.description ?? '';
      _selectedIconIndex = widget.habitToEdit!.iconIndex;
      _selectedColorIndex = widget.habitToEdit!.colorIndex;
      _selectedCategory = widget.habitToEdit!.category;
      _selectedDays = List.from(widget.habitToEdit!.scheduledDays);
      _targetDaysPerWeek = widget.habitToEdit!.targetDaysPerWeek;
      if (widget.habitToEdit!.reminderTime != null) {
        final parts = widget.habitToEdit!.reminderTime!.split(':');
        _reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final habitProvider = context.read<HabitProvider>();
    final reminderTimeStr = _reminderTime != null
        ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
        : null;

    if (isEditing) {
      final updatedHabit = widget.habitToEdit!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        iconIndex: _selectedIconIndex,
        colorIndex: _selectedColorIndex,
        category: _selectedCategory,
        scheduledDays: _selectedDays,
        targetDaysPerWeek: _targetDaysPerWeek,
        reminderTime: reminderTimeStr,
      );
      await habitProvider.updateHabit(updatedHabit);
    } else {
      await habitProvider.addHabit(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        iconIndex: _selectedIconIndex,
        colorIndex: _selectedColorIndex,
        category: _selectedCategory,
        scheduledDays: _selectedDays,
        targetDaysPerWeek: _targetDaysPerWeek,
        reminderTime: reminderTimeStr,
      );
    }

    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Habit' : 'New Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name input with autocomplete
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: _buildHabitNameField(),
              ),
              const SizedBox(height: 20),
              // Description input
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                child: _buildTextField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  hint: 'Add a description...',
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 24),
              // Icon picker
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 200),
                child: _buildIconPicker(),
              ),
              const SizedBox(height: 24),
              // Color picker
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 300),
                child: _buildColorPicker(),
              ),
              const SizedBox(height: 24),
              // Category picker
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 400),
                child: _buildCategoryPicker(),
              ),
              const SizedBox(height: 24),
              // Day selector
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 500),
                child: _buildDaySelector(),
              ),
              const SizedBox(height: 24),
              // Target days slider
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 600),
                child: _buildTargetSlider(),
              ),
              const SizedBox(height: 24),
              // Reminder time
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 700),
                child: _buildReminderPicker(),
              ),
              const SizedBox(height: 32),
              // Save button
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 800),
                child: GradientButton(
                  text: isEditing ? 'Save Changes' : 'Create Habit',
                  onPressed: _saveHabit,
                  isLoading: _isLoading,
                  width: double.infinity,
                  gradient: AppColors.habitGradients[_selectedColorIndex],
                  icon: isEditing ? Icons.save : Icons.add,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitNameField() {
    // Combine good and bad habits for suggestions
    final allHabits = [
      ...HabitSuggestions.goodHabits.map((h) => {...h, 'isQuit': false}),
      ...HabitSuggestions.badHabits.map((h) => {...h, 'isQuit': true}),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Habit Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
            return allHabits.where((habit) {
              return (habit['name'] as String)
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: (Map<String, dynamic> option) =>
              option['name'] as String,
          onSelected: (Map<String, dynamic> selection) {
            _nameController.text = selection['name'] as String;
            // Auto-populate category
            if (selection['category'] != null) {
              setState(() {
                _selectedCategory = selection['category'] as String;
              });
            }
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController fieldController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            // Sync with our main controller
            fieldController.text = _nameController.text;
            fieldController.addListener(() {
              _nameController.text = fieldController.text;
            });

            return TextFormField(
              controller: fieldController,
              focusNode: focusNode,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit name';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'e.g., Morning Exercise',
              ),
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<Map<String, dynamic>> onSelected,
              Iterable<Map<String, dynamic>> options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final option = options.elementAt(index);
                      final isQuit = option['isQuit'] as bool? ?? false;
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(25),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                option['icon'] as String,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option['name'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${option['category']} ${isQuit ? '(Quit)' : '(Build)'}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha(153),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget _buildIconPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icon',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: AppConstants.habitIcons.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedIconIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedIconIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? AppColors.habitGradients[_selectedColorIndex]
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(25),
                          ),
                  ),
                  child: Icon(
                    AppConstants.habitIcons[index],
                    size: 24,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppColors.habitGradients.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedColorIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.habitGradients[index],
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.habitGradients[index].colors.first
                                  .withAlpha(102),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.habitCategories.map((category) {
            final isSelected = category == _selectedCategory;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.habitGradients[_selectedColorIndex]
                      : null,
                  color: isSelected
                      ? null
                      : Theme.of(context).colorScheme.onSurface.withAlpha(13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final isSelected = _selectedDays.contains(index);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDays.remove(index);
                  } else {
                    _selectedDays.add(index);
                  }
                  _selectedDays.sort();
                  _targetDaysPerWeek = _selectedDays.length;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.habitGradients[_selectedColorIndex]
                      : null,
                  color: isSelected
                      ? null
                      : Theme.of(context).colorScheme.onSurface.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    AppConstants.daysOfWeek[index][0],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTargetSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Target Days per Week',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.habitGradients[_selectedColorIndex],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_targetDaysPerWeek days',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.habitGradients[_selectedColorIndex].colors.first,
            thumbColor: AppColors.habitGradients[_selectedColorIndex].colors.first,
          ),
          child: Slider(
            value: _targetDaysPerWeek.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            onChanged: (value) {
              setState(() => _targetDaysPerWeek = value.toInt());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderPicker() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      onTap: () => _selectReminderTime(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.habitGradients[_selectedColorIndex],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reminder',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _reminderTime != null
                      ? _reminderTime!.format(context)
                      : 'No reminder set',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          if (_reminderTime != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => setState(() => _reminderTime = null),
            ),
        ],
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }
}
