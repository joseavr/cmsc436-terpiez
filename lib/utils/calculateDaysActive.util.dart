/// The function calculates the number of days active
/// given the date the user started playing the game
/// * `daysPlayed` - The date the user started playing the game
/// * `return` - The number of days active
int calculateDaysActive(DateTime firstTimeActive) {
  return DateTime.now().difference(firstTimeActive).inDays;
}
