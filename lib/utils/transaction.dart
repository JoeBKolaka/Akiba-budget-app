class Transaction {
  String getDayName(DateTime dateTime) {
    switch (dateTime.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  DateTime startOfWeekDate() {
    DateTime? startOfWeek;

    DateTime today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      if (getDayName(today.subtract(Duration(days: i))) == 'Sun') {
        startOfWeek = today.subtract(Duration(days: i));
      }
    }
    return startOfWeek!;
  }

  String getMonthName(DateTime dateTime) {
    switch (dateTime.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  DateTime startOfMonthDate() {
    DateTime? startOfMonth;

    DateTime month = DateTime.now();

    for (int i = 0; i < 12; i++) {
      if (getMonthName(month.subtract(Duration())) == 'Jan') {
        startOfMonth = month.subtract(Duration());
      }
    }

    return startOfMonth!;
  }
  //Map<String,double> calculateDailyExpenseSummary() {
  //  Map<String,double> = dailyExpenseSummary = {
  //    //date(yyymmdd) : ammountTotalForDay 
  //  };
  //  for (var expense in overallExpenseList) {
  //    String date = expense.dateTime
  //    double ammount = double.parse(expense.ammount);

  //    if (dailyExpenseSummary.containsKey(date)) {
  //      double currentAmount = dailyExpenseSummary[data]!;
  //      currentAmount += amount;
  //      dailyExpenseSummary[data]=currentAmount;
  //    }else{
  //      dailyExpenseSummary.addAll((date:ammount));
  //    }
  //  }
  //  return dailyExpenseSummary;//
  //}
}

const transactions = [
  {
    "id": 1,
    "name": "Pizza Night",
    "emoji": "🍕",
    "color": "255,107,107,1.0",
    "amount": 24.99,
    "type": "expense",
    "date": "2024-01-15",
  },
  {
    "id": 2,
    "name": "Uber Ride",
    "emoji": "🚗",
    "color": "92,124,255,1.0",
    "amount": 15.50,
    "type": "expense",
    "date": "2024-01-15",
  },
  {
    "id": 3,
    "name": "Groceries",
    "emoji": "🛒",
    "color": "255,167,92,1.0",
    "amount": 85.75,
    "type": "expense",
    "date": "2024-01-14",
  },
  {
    "id": 4,
    "name": "Netflix",
    "emoji": "📱",
    "color": "167,92,255,1.0",
    "amount": 15.99,
    "type": "expense",
    "date": "2024-01-14",
  },
  {
    "id": 5,
    "name": "Electricity Bill",
    "emoji": "💡",
    "color": "255,219,92,1.0",
    "amount": 120.00,
    "type": "expense",
    "date": "2024-01-13",
  },
  {
    "id": 6,
    "name": "Dentist",
    "emoji": "🏥",
    "color": "92,255,219,1.0",
    "amount": 150.00,
    "type": "expense",
    "date": "2024-01-12",
  },
  {
    "id": 7,
    "name": "Salary",
    "emoji": "💵",
    "color": "92,255,140,1.0",
    "amount": 3500.00,
    "type": "income",
    "date": "2024-01-12",
  },
  {
    "id": 8,
    "name": "Flight Tickets",
    "emoji": "✈️",
    "color": "107,219,255,1.0",
    "amount": 450.00,
    "type": "expense",
    "date": "2024-01-11",
  },
  {
    "id": 9,
    "name": "Haircut",
    "emoji": "💇",
    "color": "255,107,219,1.0",
    "amount": 35.00,
    "type": "expense",
    "date": "2024-01-10",
  },
  {
    "id": 10,
    "name": "Emergency Fund",
    "emoji": "💰",
    "color": "124,255,92,1.0",
    "amount": 200.00,
    "type": "expense",
    "date": "2024-01-10",
  },
  {
    "id": 11,
    "name": "January Rent",
    "emoji": "🏠",
    "color": "255,140,92,1.0",
    "amount": 1200.00,
    "type": "expense",
    "date": "2024-01-09",
  },
  {
    "id": 12,
    "name": "Freelance Work",
    "emoji": "💻",
    "color": "92,140,255,1.0",
    "amount": 800.00,
    "type": "income",
    "date": "2024-01-08",
  },
  {
    "id": 13,
    "name": "Spotify",
    "emoji": "🎵",
    "color": "255,92,219,1.0",
    "amount": 10.99,
    "type": "expense",
    "date": "2024-01-08",
  },
  {
    "id": 14,
    "name": "Birthday Gift",
    "emoji": "🎁",
    "color": "255,92,140,1.0",
    "amount": 50.00,
    "type": "expense",
    "date": "2024-01-07",
  },
  {
    "id": 15,
    "name": "Gym Membership",
    "emoji": "💪",
    "color": "92,167,255,1.0",
    "amount": 45.00,
    "type": "expense",
    "date": "2024-01-07",
  },
  {
    "id": 16,
    "name": "Pet Food",
    "emoji": "🐕",
    "color": "255,182,92,1.0",
    "amount": 65.00,
    "type": "expense",
    "date": "2024-01-06",
  },
  {
    "id": 17,
    "name": "Paint Supplies",
    "emoji": "🔨",
    "color": "167,140,255,1.0",
    "amount": 120.50,
    "type": "expense",
    "date": "2024-01-05",
  },
  {
    "id": 18,
    "name": "Starbucks",
    "emoji": "☕",
    "color": "140,92,92,1.0",
    "amount": 5.75,
    "type": "expense",
    "date": "2024-01-05",
  },
  {
    "id": 19,
    "name": "Weekly Groceries",
    "emoji": "🛒",
    "color": "92,255,167,1.0",
    "amount": 95.30,
    "type": "expense",
    "date": "2024-01-04",
  },
  {
    "id": 20,
    "name": "Oil Change",
    "emoji": "🔧",
    "color": "255,124,92,1.0",
    "amount": 75.00,
    "type": "expense",
    "date": "2024-01-03",
  },
  {
    "id": 21,
    "name": "Movie Tickets",
    "emoji": "🎬",
    "color": "167,92,255,1.0",
    "amount": 28.00,
    "type": "expense",
    "date": "2024-01-03",
  },
  {
    "id": 22,
    "name": "Gas Station",
    "emoji": "⛽",
    "color": "255,200,92,1.0",
    "amount": 45.25,
    "type": "expense",
    "date": "2024-01-02",
  },
  {
    "id": 23,
    "name": "Book Purchase",
    "emoji": "📚",
    "color": "107,255,107,1.0",
    "amount": 22.99,
    "type": "expense",
    "date": "2024-01-02",
  },
  {
    "id": 24,
    "name": "Stock Dividend",
    "emoji": "📈",
    "color": "92,255,92,1.0",
    "amount": 125.50,
    "type": "income",
    "date": "2024-01-01",
  },
  {
    "id": 25,
    "name": "New Shoes",
    "emoji": "👟",
    "color": "255,140,200,1.0",
    "amount": 89.99,
    "type": "expense",
    "date": "2023-12-30",
  },
  {
    "id": 26,
    "name": "Restaurant Dinner",
    "emoji": "🍽️",
    "color": "255,107,107,1.0",
    "amount": 68.45,
    "type": "expense",
    "date": "2023-12-29",
  },
  {
    "id": 27,
    "name": "Taxi",
    "emoji": "🚖",
    "color": "92,124,255,1.0",
    "amount": 22.80,
    "type": "expense",
    "date": "2023-12-28",
  },
  {
    "id": 28,
    "name": "Clothing",
    "emoji": "👕",
    "color": "255,167,92,1.0",
    "amount": 120.00,
    "type": "expense",
    "date": "2023-12-27",
  },
  {
    "id": 29,
    "name": "Concert Tickets",
    "emoji": "🎫",
    "color": "167,92,255,1.0",
    "amount": 150.00,
    "type": "expense",
    "date": "2023-12-26",
  },
  {
    "id": 30,
    "name": "Water Bill",
    "emoji": "🚿",
    "color": "255,219,92,1.0",
    "amount": 45.60,
    "type": "expense",
    "date": "2023-12-25",
  },
  {
    "id": 31,
    "name": "Doctor Visit",
    "emoji": "👨‍⚕️",
    "color": "92,255,219,1.0",
    "amount": 75.00,
    "type": "expense",
    "date": "2023-12-24",
  },
  {
    "id": 32,
    "name": "Bonus",
    "emoji": "🎉",
    "color": "255,255,107,1.0",
    "amount": 500.00,
    "type": "income",
    "date": "2023-12-24",
  },
  {
    "id": 33,
    "name": "Hotel Booking",
    "emoji": "🏨",
    "color": "107,219,255,1.0",
    "amount": 320.00,
    "type": "expense",
    "date": "2023-12-23",
  },
  {
    "id": 34,
    "name": "Spa Day",
    "emoji": "🧖",
    "color": "255,107,219,1.0",
    "amount": 85.00,
    "type": "expense",
    "date": "2023-12-22",
  },
  {
    "id": 35,
    "name": "Investment",
    "emoji": "📊",
    "color": "124,255,92,1.0",
    "amount": 300.00,
    "type": "expense",
    "date": "2023-12-21",
  },
  {
    "id": 36,
    "name": "December Rent",
    "emoji": "🏠",
    "color": "255,140,92,1.0",
    "amount": 1200.00,
    "type": "expense",
    "date": "2023-12-20",
  },
  {
    "id": 37,
    "name": "Consulting Fee",
    "emoji": "💼",
    "color": "92,140,255,1.0",
    "amount": 1200.00,
    "type": "income",
    "date": "2023-12-19",
  },
  {
    "id": 38,
    "name": "YouTube Premium",
    "emoji": "▶️",
    "color": "255,92,219,1.0",
    "amount": 11.99,
    "type": "expense",
    "date": "2023-12-19",
  },
  {
    "id": 39,
    "name": "Charity Donation",
    "emoji": "🤝",
    "color": "255,92,140,1.0",
    "amount": 100.00,
    "type": "expense",
    "date": "2023-12-18",
  },
  {
    "id": 40,
    "name": "Yoga Class",
    "emoji": "🧘",
    "color": "92,167,255,1.0",
    "amount": 20.00,
    "type": "expense",
    "date": "2023-12-17",
  },
  {
    "id": 41,
    "name": "Vet Bill",
    "emoji": "🐾",
    "color": "255,182,92,1.0",
    "amount": 180.00,
    "type": "expense",
    "date": "2023-12-16",
  },
  {
    "id": 42,
    "name": "Light Bulbs",
    "emoji": "💡",
    "color": "167,140,255,1.0",
    "amount": 15.99,
    "type": "expense",
    "date": "2023-12-15",
  },
  {
    "id": 43,
    "name": "Coffee Beans",
    "emoji": "☕",
    "color": "140,92,92,1.0",
    "amount": 18.50,
    "type": "expense",
    "date": "2023-12-14",
  },
  {
    "id": 44,
    "name": "Bulk Groceries",
    "emoji": "🛒",
    "color": "92,255,167,1.0",
    "amount": 150.75,
    "type": "expense",
    "date": "2023-12-13",
  },
  {
    "id": 45,
    "name": "Car Wash",
    "emoji": "🚗",
    "color": "255,124,92,1.0",
    "amount": 25.00,
    "type": "expense",
    "date": "2023-12-12",
  },
  {
    "id": 46,
    "name": "Amazon Prime",
    "emoji": "📦",
    "color": "255,140,107,1.0",
    "amount": 139.00,
    "type": "expense",
    "date": "2023-12-11",
  },
  {
    "id": 47,
    "name": "Phone Bill",
    "emoji": "📞",
    "color": "107,200,255,1.0",
    "amount": 65.00,
    "type": "expense",
    "date": "2023-12-10",
  },
  {
    "id": 48,
    "name": "Tax Refund",
    "emoji": "💰",
    "color": "92,255,92,1.0",
    "amount": 850.00,
    "type": "income",
    "date": "2023-12-09",
  },
  {
    "id": 49,
    "name": "Gaming Console",
    "emoji": "🎮",
    "color": "255,107,200,1.0",
    "amount": 399.99,
    "type": "expense",
    "date": "2023-12-08",
  },
  {
    "id": 50,
    "name": "Lunch with Friends",
    "emoji": "🍔",
    "color": "255,150,107,1.0",
    "amount": 35.25,
    "type": "expense",
    "date": "2023-12-07",
  },
];
