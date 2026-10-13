const API_BASE = 'http://localhost:8080/api';

document.addEventListener('DOMContentLoaded', () => {
    loadProperties();

    document.getElementById('statusFilter').addEventListener('change', loadProperties);
    document.getElementById('cityFilter').addEventListener('change', loadProperties);
});

function formatCurrency(amount) {
    if (amount === null || amount === undefined) return '₹0';
    return new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR',
        maximumFractionDigits: 0
    }).format(amount);
}

async function loadProperties() {
    const status = document.getElementById('statusFilter').value;
    const city = document.getElementById('cityFilter').value;
    const container = document.getElementById('properties-container');
    container.innerHTML = '<div class="col-12 text-center py-5"><div class="spinner-border text-primary" role="status"></div></div>';

    try {
        let url = `${API_BASE}/properties`;
        const params = new URLSearchParams();
        if (status) params.append('status', status);
        if (city) params.append('city', city);
        if (params.toString()) url += `?${params.toString()}`;

        const res = await fetch(url);
        const data = await res.json();
        container.innerHTML = '';

        if (!data || data.length === 0) {
            container.innerHTML = '<div class="col-12 text-center py-5 text-muted">No properties found matching your filter criteria.</div>';
            return;
        }

        data.forEach(p => {
            let statusBadge = 'badge-occupied';
            if (p.status === 'vacant') statusBadge = 'badge-vacant';
            else if (p.status === 'under_maintenance') statusBadge = 'badge-maintenance';

            const card = `
                <div class="col-12 col-md-6 col-xl-4">
                    <div class="property-card p-4 h-100 d-flex flex-column justify-content-between">
                        <div>
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <span class="badge bg-light text-dark border text-capitalize">${p.propertyType}</span>
                                <span class="badge ${statusBadge} text-capitalize">${p.status.replace('_', ' ')}</span>
                            </div>
                            <h5 class="fw-bold mb-1">${p.title}</h5>
                            <p class="text-muted small mb-3">
                                <i class="fa-solid fa-location-dot me-1 text-danger"></i>${p.address}, ${p.city}, ${p.state}
                            </p>
                            <div class="d-flex gap-3 mb-3 text-secondary small">
                                <span><i class="fa-solid fa-bed me-1"></i>${p.bedrooms} Beds</span>
                                <span><i class="fa-solid fa-bath me-1"></i>${p.bathrooms} Baths</span>
                                <span><i class="fa-solid fa-vector-square me-1"></i>${p.areaSqft || '—'} sqft</span>
                            </div>
                        </div>
                        <div class="pt-3 border-top d-flex justify-content-between align-items-center">
                            <div>
                                <small class="text-muted d-block">Monthly Rent</small>
                                <span class="fs-5 fw-bold text-primary">${formatCurrency(p.rentAmount)}</span>
                            </div>
                            <div class="text-end">
                                <small class="text-muted d-block">Owner</small>
                                <span class="fw-semibold small">${p.owner ? p.owner.fullName : '—'}</span>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            container.innerHTML += card;
        });
    } catch (err) {
        console.error('Failed to load properties:', err);
        container.innerHTML = '<div class="col-12 text-center text-danger py-4">Failed to load properties from backend.</div>';
    }
}
