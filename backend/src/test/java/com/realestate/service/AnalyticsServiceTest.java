package com.realestate.service;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class AnalyticsServiceTest {

    @Autowired
    private AnalyticsService analyticsService;

    @Test
    @DisplayName("Should return valid occupancy statistics")
    void testGetOccupancyStats() {
        Map<String, Object> stats = analyticsService.getOccupancyStats();
        assertNotNull(stats, "Occupancy stats should not be null");
        assertTrue(stats.containsKey("total_properties"), "Should contain total_properties key");
        assertTrue(stats.containsKey("occupancy_rate"), "Should contain occupancy_rate key");
        Number total = (Number) stats.get("total_properties");
        assertTrue(total.intValue() > 0, "Total properties should be greater than 0");
    }

    @Test
    @DisplayName("Should return top 5 revenue-generating properties")
    void testGetTopProperties() {
        List<Map<String, Object>> topProps = analyticsService.getTopProperties();
        assertNotNull(topProps, "Top properties list should not be null");
        assertFalse(topProps.isEmpty(), "Top properties list should not be empty");
        assertTrue(topProps.size() <= 5, "Should return at most 5 properties");
    }

    @Test
    @DisplayName("Should calculate monthly rental income and growth")
    void testGetMonthlyIncome() {
        List<Map<String, Object>> monthly = analyticsService.getMonthlyIncome();
        assertNotNull(monthly, "Monthly income should not be null");
        assertFalse(monthly.isEmpty(), "Monthly income should have historical records");
    }

    @Test
    @DisplayName("Should return overdue aging buckets")
    void testGetOverdueSummary() {
        List<Map<String, Object>> aging = analyticsService.getOverdueSummary();
        assertNotNull(aging, "Overdue aging list should not be null");
    }
}
