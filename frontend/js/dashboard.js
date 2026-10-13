const API_BASE = 'http://localhost:8080/api';

document.addEventListener('DOMContentLoaded', () => {
    loadOccupancyKPIs();
    loadMonthlyIncomeChart();
    loadTopPropertiesChart();
    loadOccupancyChart();
    loadExpenseBreakdownChart();
    loadOverdueAgingTable();
    loadNetIncomeTable();
    loadVacantPropertiesTable();
    loadYieldAnalyticsTable();
});

// Format Currency in INR
function formatCurrency(amount) {
    if (amount === null || amount === undefined) return '₹0';
    return new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR',
        maximumFractionDigits: 0
    }).format(amount);
}

// 1. Occupancy & Summary KPIs
async function loadOccupancyKPIs() {
    try {
        const res = await fetch(`${API_BASE}/analytics/occupancy`);
        const data = await res.json();
        
        document.getElementById('kpi-total-properties').innerText = data.total_properties || 0;
        document.getElementById('kpi-occupied').innerText = data.occupied || 0;
        document.getElementById('kpi-vacant').innerText = data.vacant || 0;
        document.getElementById('kpi-occupancy-rate').innerText = `${data.occupancy_rate || 0}%`;
    } catch (err) {
        console.error('Failed to load occupancy KPIs:', err);
    }
}

// 2. Chart: Monthly Rental Income Trend + MoM Growth
async function loadMonthlyIncomeChart() {
    try {
        const res = await fetch(`${API_BASE}/analytics/monthly-income`);
        const data = await res.json();

        const labels = data.map(item => item.payment_month);
        const totals = data.map(item => item.monthly_total);
        const growthRates = data.map(item => item.mom_growth_pct || 0);

        const ctx = document.getElementById('monthlyIncomeChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Rental Income (₹)',
                        data: totals,
                        borderColor: '#2563eb',
                        backgroundColor: 'rgba(37, 99, 235, 0.1)',
                        fill: true,
                        tension: 0.35,
                        yAxisID: 'y'
                    },
                    {
                        label: 'MoM Growth (%)',
                        data: growthRates,
                        borderColor: '#10b981',
                        borderDash: [5, 5],
                        fill: false,
                        tension: 0.2,
                        yAxisID: 'y1'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        ticks: {
                            callback: value => '₹' + (value / 1000) + 'k'
                        }
                    },
                    y1: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        grid: { drawOnChartArea: false },
                        ticks: {
                            callback: value => value + '%'
                        }
                    }
                }
            }
        });
    } catch (err) {
        console.error('Failed to load monthly income chart:', err);
    }
}

// 3. Chart: Top 5 Properties by Revenue
async function loadTopPropertiesChart() {
    try {
        const res = await fetch(`${API_BASE}/analytics/top-properties`);
        const data = await res.json();

        const labels = data.map(item => item.title);
        const revenues = data.map(item => item.total_income_12m);

        const ctx = document.getElementById('topPropertiesChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Total Collected (₹)',
                    data: revenues,
                    backgroundColor: [
                        '#3b82f6', '#60a5fa', '#93c5fd', '#bfdbfe', '#dbeafe'
                    ],
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        ticks: {
                            callback: value => '₹' + (value / 1000) + 'k'
                        }
                    }
                }
            }
        });
    } catch (err) {
        console.error('Failed to load top properties chart:', err);
    }
}

// 4. Chart: Occupancy Rate Breakdown
async function loadOccupancyChart() {
    try {
        const res = await fetch(`${API_BASE}/analytics/occupancy`);
        const data = await res.json();

        const ctx = document.getElementById('occupancyChart').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Occupied', 'Vacant', 'Under Maintenance'],
                datasets: [{
                    data: [data.occupied, data.vacant, data.under_maintenance],
                    backgroundColor: ['#10b981', '#ef4444', '#f59e0b']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });
    } catch (err) {
        console.error('Failed to load occupancy chart:', err);
    }
}

// 5. Chart: Expense Category Breakdown
async function loadExpenseBreakdownChart() {
    try {
        const res = await fetch(`${API_BASE}/analytics/expense-breakdown`);
        const data = await res.json();

        const labels = data.map(item => item.category);
        const amounts = data.map(item => item.total_amount);

        const ctx = document.getElementById('expenseChart').getContext('2d');
        new Chart(ctx, {
            type: 'pie',
            data: {
                labels: labels,
                datasets: [{
                    data: amounts,
                    backgroundColor: [
                        '#ef4444', '#f97316', '#eab308', '#06b6d4', '#6366f1', '#ec4899', '#8b5cf6'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });
    } catch (err) {
        console.error('Failed to load expense breakdown chart:', err);
    }
}

// 6. Table: Overdue Payment Aging
async function loadOverdueAgingTable() {
    try {
        const res = await fetch(`${API_BASE}/analytics/overdue-aging`);
        const data = await res.json();
        const tbody = document.getElementById('overdue-table-body');
        tbody.innerHTML = '';

        if (!data || data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted">No overdue payments recorded</td></tr>';
            return;
        }

        data.forEach(item => {
            let badgeClass = 'badge-partial';
            if (item.aging_bucket === '60+ days') badgeClass = 'badge-overdue';
            else if (item.aging_bucket === '0–30 days') badgeClass = 'badge-pending';

            const row = `
                <tr>
                    <td class="fw-bold">${item.tenant_name}</td>
                    <td>${item.property_title}</td>
                    <td class="text-danger fw-bold">${formatCurrency(item.balance_due)}</td>
                    <td>${item.due_date}</td>
                    <td>${item.days_overdue} days</td>
                    <td><span class="badge ${badgeClass}">${item.aging_bucket}</span></td>
                </tr>
            `;
            tbody.innerHTML += row;
        });
    } catch (err) {
        console.error('Failed to load overdue aging table:', err);
    }
}

// 7. Table: Net Income Per Property
async function loadNetIncomeTable() {
    try {
        const res = await fetch(`${API_BASE}/analytics/net-income`);
        const data = await res.json();
        const tbody = document.getElementById('net-income-table-body');
        tbody.innerHTML = '';

        data.forEach(item => {
            const net = item.net_income;
            const netColor = net >= 0 ? 'text-success' : 'text-danger';

            const row = `
                <tr>
                    <td class="fw-bold">${item.title}</td>
                    <td>${item.city}</td>
                    <td><span class="badge bg-light text-dark text-capitalize">${item.property_type}</span></td>
                    <td>${item.owner_name}</td>
                    <td>${formatCurrency(item.total_rent_collected)}</td>
                    <td>${formatCurrency(item.total_expenses)}</td>
                    <td class="fw-bold ${netColor}">${formatCurrency(net)}</td>
                </tr>
            `;
            tbody.innerHTML += row;
        });
    } catch (err) {
        console.error('Failed to load net income table:', err);
    }
}

// 8. Table: Vacant Properties > 60 Days
async function loadVacantPropertiesTable() {
    try {
        const res = await fetch(`${API_BASE}/analytics/vacant-properties`);
        const data = await res.json();
        const tbody = document.getElementById('vacant-table-body');
        tbody.innerHTML = '';

        if (!data || data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">No long-term vacant properties</td></tr>';
            return;
        }

        data.forEach(item => {
            const row = `
                <tr>
                    <td class="fw-bold">${item.title}</td>
                    <td>${item.city}</td>
                    <td>${formatCurrency(item.rent_amount)}/mo</td>
                    <td><span class="badge badge-overdue">${item.days_vacant ? item.days_vacant + ' days' : 'Brand New'}</span></td>
                    <td class="text-danger fw-bold">${formatCurrency(item.estimated_lost_income)}</td>
                </tr>
            `;
            tbody.innerHTML += row;
        });
    } catch (err) {
        console.error('Failed to load vacant properties table:', err);
    }
}

// 9. Table: Gross Rental Yield Analytics
async function loadYieldAnalyticsTable() {
    try {
        const res = await fetch(`${API_BASE}/analytics/yield`);
        const data = await res.json();
        const tbody = document.getElementById('yield-table-body');
        tbody.innerHTML = '';

        data.forEach(item => {
            let badgeClass = 'badge-medium';
            if (item.yield_rating === 'Excellent' || item.yield_rating === 'Good') badgeClass = 'badge-high';
            else if (item.yield_rating === 'Poor') badgeClass = 'badge-low';

            const row = `
                <tr>
                    <td class="fw-bold">${item.title}</td>
                    <td>${item.city}</td>
                    <td>${formatCurrency(item.annual_rent)}</td>
                    <td>${formatCurrency(item.latest_valuation)}</td>
                    <td class="fw-bold">${item.gross_yield_pct}%</td>
                    <td><span class="badge ${badgeClass}">${item.yield_rating}</span></td>
                </tr>
            `;
            tbody.innerHTML += row;
        });
    } catch (err) {
        console.error('Failed to load yield table:', err);
    }
}
