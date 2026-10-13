package com.realestate.service;

import com.realestate.repository.AnalyticsRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Service
public class AnalyticsService {

    private final AnalyticsRepository analyticsRepository;

    public AnalyticsService(AnalyticsRepository analyticsRepository) {
        this.analyticsRepository = analyticsRepository;
    }

    public List<Map<String, Object>> getTopProperties() {
        return analyticsRepository.getTopRevenueProperties();
    }

    public List<Map<String, Object>> getMonthlyIncome() {
        return analyticsRepository.getMonthlyIncomeGrowth();
    }

    public List<Map<String, Object>> getOverdueSummary() {
        return analyticsRepository.getOverdueAgingReport();
    }

    public List<Map<String, Object>> getVacantProperties() {
        return analyticsRepository.getLongTermVacantProperties();
    }

    public List<Map<String, Object>> getNetIncome() {
        return analyticsRepository.getPropertyNetIncome();
    }

    public List<Map<String, Object>> getYieldAnalytics() {
        return analyticsRepository.getPropertyGrossYield();
    }

    public List<Map<String, Object>> getOwnerPortfolios() {
        return analyticsRepository.getOwnerPortfolioSummary();
    }

    public List<Map<String, Object>> getExpenseBreakdown() {
        return analyticsRepository.getExpenseCategoryBreakdown();
    }

    public Map<String, Object> getOccupancyStats() {
        return analyticsRepository.getOccupancyStats();
    }

    public Map<String, Object> closeLease(Integer agreementId, LocalDate endDate) {
        return analyticsRepository.callCloseLeaseProcedure(agreementId, endDate);
    }

    public List<Map<String, Object>> getMonthlyReport(int year, int month) {
        return analyticsRepository.callGetMonthlyReportProcedure(year, month);
    }
}
