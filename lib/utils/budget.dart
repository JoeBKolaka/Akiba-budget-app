// Current date for reference
const currentDate = "2024-01-15"; // Monday

const budgets = [
  {
    "id": 1,
    "name": "Groceries",
    "emoji": "🛒",
    "period": "weekly",
    // Weekly budget resets every Monday
    "amount_spent": 85.75, // Spent this week (Jan 15-21)
    "amount_budgeted": 100.00,
    "last_reset": "2024-01-15", // Reset date
  },
  {
    "id": 2,
    "name": "Dining Out",
    "emoji": "🍽️",
    "period": "monthly",
    // Monthly budget resets on 1st of month
    "amount_spent": 128.44, // Spent in January
    "amount_budgeted": 200.00,
    "last_reset": "2024-01-01",
  },
  {
    "id": 3,
    "name": "Transportation",
    "emoji": "🚗",
    "period": "monthly",
    "amount_spent": 88.55,
    "amount_budgeted": 150.00,
    "last_reset": "2024-01-01",
  },
  {
    "id": 4,
    "name": "Entertainment",
    "emoji": "🎬",
    "period": "monthly",
    "amount_spent": 193.99, // Over budget!
    "amount_budgeted": 150.00,
    "last_reset": "2024-01-01",
  },
  {
    "id": 5,
    "name": "Coffee",
    "emoji": "☕",
    "period": "daily",
    // Daily budget resets every day
    "amount_spent": 5.75, // Spent today
    "amount_budgeted": 10.00,
    "last_reset": "2024-01-15",
  },
  {
    "id": 6,
    "name": "Utilities",
    "emoji": "💡",
    "period": "monthly",
    "amount_spent": 165.60,
    "amount_budgeted": 180.00,
    "last_reset": "2024-01-01",
  },
  {
    "id": 7,
    "name": "Shopping",
    "emoji": "🛍️",
    "period": "weekly",
    "amount_spent": 45.00,
    "amount_budgeted": 75.00,
    "last_reset": "2024-01-15",
  },
  {
    "id": 8,
    "name": "Fitness",
    "emoji": "💪",
    "period": "monthly",
    "amount_spent": 45.00,
    "amount_budgeted": 50.00,
    "last_reset": "2024-01-01",
  },
  {
    "id": 9,
    "name": "Personal Care",
    "emoji": "💇",
    "period": "monthly",
    "amount_spent": 35.00,
    "amount_budgeted": 50.00,
    "last_reset": "2024-01-01",
  },
  {
    "id": 10,
    "name": "Savings",
    "emoji": "💰",
    "period": "monthly",
    "amount_spent": 500.00,
    "amount_budgeted": 500.00,
    "last_reset": "2024-01-01",
  }
];