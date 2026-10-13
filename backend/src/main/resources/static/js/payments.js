const API_BASE = 'http://localhost:8080/api';

document.addEventListener('DOMContentLoaded', () => {
    loadPayments();

    document.getElementById('statusFilter').addEventListener('change', loadPayments);
    document.getElementById('recordPaymentForm').addEventListener('submit', handleRecordPayment);
});

function formatCurrency(amount) {
    if (amount === null || amount === undefined) return '₹0';
    return new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR',
        maximumFractionDigits: 0
    }).format(amount);
}

async function loadPayments() {
    const status = document.getElementById('statusFilter').value;
    const tbody = document.getElementById('payments-table-body');
    tbody.innerHTML = '<tr><td colspan="8" class="text-center py-4"><div class="spinner-border text-primary" role="status"></div></td></tr>';

    try {
        let url = `${API_BASE}/payments`;
        if (status) url += `?status=${status}`;

        const res = await fetch(url);
        const data = await res.json();
        tbody.innerHTML = '';

        if (!data || data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8" class="text-center py-4 text-muted">No payment records found.</td></tr>';
            return;
        }

        data.forEach(p => {
            let statusBadge = 'badge-pending';
            if (p.status === 'paid') statusBadge = 'badge-paid';
            else if (p.status === 'overdue') statusBadge = 'badge-overdue';
            else if (p.status === 'partial') statusBadge = 'badge-partial';

            const lease = p.rentalAgreement;
            const propertyTitle = lease && lease.property ? lease.property.title : '—';
            const tenantName = lease && lease.tenant ? lease.tenant.fullName : '—';

            const row = `
                <tr>
                    <td class="fw-bold">#${p.paymentId}</td>
                    <td>${tenantName}</td>
                    <td>${propertyTitle}</td>
                    <td>${formatCurrency(p.amountDue)}</td>
                    <td class="fw-semibold text-success">${formatCurrency(p.amountPaid)}</td>
                    <td>${p.dueDate}</td>
                    <td><span class="badge ${statusBadge} text-capitalize">${p.status}</span></td>
                    <td class="text-capitalize small text-muted">${p.paymentMode ? p.paymentMode.replace('_', ' ') : '—'}</td>
                </tr>
            `;
            tbody.innerHTML += row;
        });
    } catch (err) {
        console.error('Failed to load payments:', err);
        tbody.innerHTML = '<tr><td colspan="8" class="text-center text-danger py-4">Error loading payments from server.</td></tr>';
    }
}

async function handleRecordPayment(e) {
    e.preventDefault();
    const btn = document.getElementById('submitBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Processing...';

    const agreementId = document.getElementById('agreementId').value;
    const amount = document.getElementById('amount').value;
    const paymentDate = document.getElementById('paymentDate').value;
    const paymentMode = document.getElementById('paymentMode').value;

    const alertContainer = document.getElementById('formAlert');
    alertContainer.innerHTML = '';

    try {
        const params = new URLSearchParams({
            agreementId: agreementId,
            amount: amount,
            paymentDate: paymentDate,
            paymentMode: paymentMode
        });

        const res = await fetch(`${API_BASE}/payments/record?${params.toString()}`, {
            method: 'POST'
        });

        const data = await res.json();

        if (res.ok) {
            alertContainer.innerHTML = `
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i> ${data.message || 'Payment recorded successfully!'}
                    (New Status: <strong>${data.new_status || 'Paid'}</strong>)
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            `;
            document.getElementById('recordPaymentForm').reset();
            loadPayments();
        } else {
            throw new Error(data.message || 'Failed to record payment');
        }
    } catch (err) {
        alertContainer.innerHTML = `
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2"></i> ${err.message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        `;
    } finally {
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> Submit Payment (Runs Stored Procedure)';
    }
}
