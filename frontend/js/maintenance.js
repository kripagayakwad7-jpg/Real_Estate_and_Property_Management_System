const API_BASE = 'http://localhost:8080/api';

document.addEventListener('DOMContentLoaded', () => {
    loadMaintenanceRequests();
    loadPropertiesDropdown();

    document.getElementById('statusFilter').addEventListener('change', loadMaintenanceRequests);
    document.getElementById('maintenanceForm').addEventListener('submit', handleNewRequest);
});

async function loadPropertiesDropdown() {
    try {
        const res = await fetch(`${API_BASE}/properties`);
        const properties = await res.json();
        const select = document.getElementById('propertySelect');
        select.innerHTML = '<option value="">Select Property...</option>';

        properties.forEach(p => {
            select.innerHTML += `<option value="${p.propertyId}">${p.title} (${p.city})</option>`;
        });
    } catch (err) {
        console.error('Failed to load properties dropdown:', err);
    }
}

async function loadMaintenanceRequests() {
    const status = document.getElementById('statusFilter').value;
    const tbody = document.getElementById('maintenance-table-body');
    tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4"><div class="spinner-border text-primary" role="status"></div></td></tr>';

    try {
        let url = `${API_BASE}/maintenance`;
        if (status) url += `?status=${status}`;

        const res = await fetch(url);
        const data = await res.json();
        tbody.innerHTML = '';

        if (!data || data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4 text-muted">No maintenance requests found.</td></tr>';
            return;
        }

        data.forEach(req => {
            let priorityBadge = 'bg-secondary';
            if (req.priority === 'urgent') priorityBadge = 'bg-danger';
            else if (req.priority === 'high') priorityBadge = 'bg-warning text-dark';
            else if (req.priority === 'medium') priorityBadge = 'bg-info text-dark';
            else if (req.priority === 'low') priorityBadge = 'bg-light text-dark border';

            let statusBadge = 'badge-pending';
            if (req.status === 'resolved' || req.status === 'closed') statusBadge = 'badge-paid';
            else if (req.status === 'in_progress') statusBadge = 'badge-partial';

            const propTitle = req.property ? req.property.title : '—';
            const tenantName = req.tenant ? req.tenant.fullName : '—';

            const row = `
                <tr>
                    <td class="fw-bold">#${req.requestId}</td>
                    <td>${propTitle}</td>
                    <td>${tenantName}</td>
                    <td>${req.description}</td>
                    <td><span class="badge ${priorityBadge} text-capitalize">${req.priority}</span></td>
                    <td><span class="badge ${statusBadge} text-capitalize">${req.status.replace('_', ' ')}</span></td>
                    <td>${req.requestDate}</td>
                </tr>
            `;
            tbody.innerHTML += row;
        });
    } catch (err) {
        console.error('Failed to load maintenance requests:', err);
        tbody.innerHTML = '<tr><td colspan="7" class="text-center text-danger py-4">Error loading maintenance requests.</td></tr>';
    }
}

async function handleNewRequest(e) {
    e.preventDefault();
    const btn = document.getElementById('submitBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Submitting...';

    const propertyId = document.getElementById('propertySelect').value;
    const description = document.getElementById('description').value;
    const priority = document.getElementById('priority').value;
    const alertContainer = document.getElementById('formAlert');
    alertContainer.innerHTML = '';

    try {
        const payload = {
            property: { propertyId: parseInt(propertyId) },
            description: description,
            priority: priority,
            status: 'open',
            requestDate: new Date().toISOString().split('T')[0]
        };

        const res = await fetch(`${API_BASE}/maintenance`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            alertContainer.innerHTML = `
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i> Maintenance request submitted successfully!
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            `;
            document.getElementById('maintenanceForm').reset();
            loadMaintenanceRequests();
        } else {
            throw new Error('Failed to submit maintenance request');
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
        btn.innerHTML = '<i class="fa-solid fa-paper-plane me-1"></i> Submit Request';
    }
}
