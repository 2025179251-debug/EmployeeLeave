import java.time.LocalDate;
import java.time.Year;
import java.time.temporal.ChronoUnit;

public class LeaveBalanceEngine {

    public static class EntitlementResult {
        public final int baseEntitlement;
        public final int proratedEntitlement;
        public EntitlementResult(int baseEntitlement, int proratedEntitlement) {
            this.baseEntitlement = baseEntitlement;
            this.proratedEntitlement = proratedEntitlement;
        }
    }

    // ✅ statutory base entitlement by service years + leave type
    public static int baseEntitlementByType(String typeCode, long serviceYears, String genderUpper) {
        String t = typeCode == null ? "" : typeCode.trim().toUpperCase();
        String g = genderUpper == null ? "" : genderUpper.trim().toUpperCase();

        switch (t) {
            case "ANNUAL":
                if (serviceYears < 2) return 8;
                if (serviceYears < 5) return 12;
                return 16;

            case "SICK":
                if (serviceYears < 2) return 14;
                if (serviceYears < 5) return 18;
                return 22;

            case "HOSPITALIZATION":
                return 60;

            case "MATERNITY":
                return "F".equals(g) || "FEMALE".equals(g) ? 98 : 0;

            // ikut polisi company (ubah kalau perlu)
            case "EMERGENCY":
                return 5;

            case "UNPAID":
                return 3;

            default:
                return 0;
        }
    }

    // ✅ compute completed service years (simple + practical)
    public static long serviceYears(LocalDate hireDate, LocalDate today) {
        if (hireDate == null) return 0;
        if (today.isBefore(hireDate)) return 0;
        return ChronoUnit.YEARS.between(hireDate, today);
    }

    // ✅ completed months in current year (for proration)
    public static int completedMonthsThisYear(LocalDate hireDate, LocalDate today) {
        if (hireDate == null) return 0;

        int year = today.getYear();
        LocalDate yearStart = LocalDate.of(year, 1, 1);

        // start counting from later of (hireDate) or (Jan 1)
        LocalDate start = hireDate.isAfter(yearStart) ? hireDate : yearStart;

        if (today.isBefore(start)) return 0;

        // "completed months": use first day of month trick
        LocalDate startMonth = start.withDayOfMonth(1);
        LocalDate thisMonth = today.withDayOfMonth(1);

        long months = ChronoUnit.MONTHS.between(startMonth, thisMonth);

        // if today already within current month, completed months exclude current running month
        // but many HR count completed months up to current month-1. We'll use that.
        int completed = (int) Math.max(0, months);

        // cap max 12
        return Math.min(12, completed);
    }

    // ✅ prorate entitlement (floor)
    public static EntitlementResult computeEntitlement(String typeCode, LocalDate hireDate, String genderUpper) {
        LocalDate today = LocalDate.now();
        long years = serviceYears(hireDate, today);
        int base = baseEntitlementByType(typeCode, years, genderUpper);

        // by default: prorate annual + sick if hired within this year, else full
        // (you can also prorate any type you want)
        int currentYear = Year.now().getValue();

        boolean hiredThisYear = (hireDate != null && hireDate.getYear() == currentYear);

        if (!hiredThisYear) {
            return new EntitlementResult(base, base);
        }

        int completedMonths = completedMonthsThisYear(hireDate, today);
        int prorated = (int) Math.floor((completedMonths / 12.0) * base);

        return new EntitlementResult(base, prorated);
    }

    // ✅ final available balance
    public static double availableDays(int entitlement, int carriedFwd, double used, double pending) {
        return (entitlement + carriedFwd) - used - pending;
    }
}
