
import 'package:my_first_flutter_project/actions/actions.dart';
import 'package:my_first_flutter_project/store/AppState.dart';
import 'package:my_first_flutter_project/store/Reminder.dart';
import 'package:my_first_flutter_project/store/RemindersState.dart';
import 'package:redux/redux.dart';

AppState appReducer(AppState state, dynamic action) => AppState(
      remindersState: remindersReducer(state.remindersState, action),
    );

final remindersReducer = combineReducers<RemindersState>([
  TypedReducer<RemindersState, SetReminderAction>(_setReminderAction),
  TypedReducer<RemindersState, ClearReminderAction>(_clearReminderAction),
  TypedReducer<RemindersState, RemoveReminderAction>(_removeReminderAction),
]);

RemindersState _setReminderAction(
    RemindersState state, SetReminderAction action) {
  var remindersList = state.reminders;
  if (remindersList != null) {
    remindersList.add(new Reminder(
        repeat: action.repeat, name: action.name, time: action.time));
  }
  return state.copyWith(reminders: remindersList);
}

RemindersState _clearReminderAction(
        RemindersState state, ClearReminderAction action) =>
    state.copyWith(reminders: []);

RemindersState _removeReminderAction(
    RemindersState state, RemoveReminderAction action) {
  var remindersList = state.reminders;
  remindersList.removeWhere((reminder) => reminder.name == action.name);
  return state.copyWith(reminders: remindersList);
}
