package com.realestate.controller;

import com.realestate.service.AnalyticsService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/analytics")
@CrossOrigin(origins = "*")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    public AnalyticsController(AnalyticsService analyticsService) {
        this.analyticsService = analyticsService;
    }

    /**
     * Q6: Top 5 properties by rental income
     */
    @GetMapping("/top-properties")
    public ResponseEntity<List<Map<String, Object>>> getTopProperties() {
        return ResponseEntity.ok(analyticsService.getTopProperties());
    }

    /**
     * Q13: Monthly income + MoM growth (CTE + LAG)
     */
    @GetMapping("/monthly-income")
    public ResponseEntity<List<Map<String, Object>>> getMonthlyIncome() {
        return ResponseEntity.ok(analyticsService.getMonthlyIncome());
    }

    /**
     * Q14: Overdue payment aging report (0-30, 31-60, 60+ days)
     */
    @GetMapping("/overdue-aging")
    public ResponseEntity<List<Map<String, Object>>> getOverdueAging() {
        return ResponseEntity.ok(analyticsService.getOverdueSummary());
    }

    /**
     * Q23: Vacant properties > 60 days
     */
    @GetMapping("/vacant-properties")
    public ResponseEntity<List<Map<String, Object>>> getVacantProperties() {
        return ResponseEntity.ok(analyticsService.getVacantProperties());
    }

    /**
     * Q24: Net income per property (rent - expenses)
     */
    @GetMapping("/net-income")
    public ResponseEntity<List<Map<String, Object>>> getNetIncome() {
        return ResponseEntity.ok(analyticsService.getNetIncome());
    }

    /**
     * Q25: Gross rental yield (%)
     */
    @GetMapping("/yield")
    public ResponseEntity<List<Map<String, Object>>> getYieldAnalytics() {
        return ResponseEntity.ok(analyticsService.getYieldAnalytics());
    }

    /**
     * Q5: Owner portfolio summary
     */
    @GetMapping("/owner-portfolios")
    public ResponseEntity<List<Map<String, Object>>> getOwnerPortfolios() {
        return ResponseEntity.ok(analyticsService.getOwnerPortfolios());
    }

    /**
     * Expense breakdown by category
     */
    @GetMapping("/expense-breakdown")
    public ResponseEntity<List<Map<String, Object>>> getExpenseBreakdown() {
        return ResponseEntity.ok(analyticsService.getExpenseBreakdown());
    }

    /**
     * Occupancy rates
     */
    @GetMapping("/occupancy")
    public ResponseEntity<Map<String, Object>> getOccupancyStats() {
        return ResponseEntity.ok(analyticsService.getOccupancyStats());
    }

    /**
     * Stored Procedure: close_lease
     */
    @PostMapping("/close-lease")
    public ResponseEntity<Map<String, Object>> closeLease(
            @RequestParam Integer agreementId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(analyticsService.closeLease(agreementId, endDate));
    }

    /**
     * Stored Procedure: get_monthly_report
     */
    @GetMapping("/monthly-report")
    public ResponseEntity<List<Map<String, Object>>> getMonthlyReport(
            @RequestParam int year,
            @RequestParam int month) {
        return ResponseEntity.ok(analyticsService.getMonthlyReport(year, month));
    }
}
