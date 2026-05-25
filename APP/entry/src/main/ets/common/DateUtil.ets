/**
 * 日期选择与格式化工具
 * 预订场景使用 CalendarPickerDialog（日历点选，平板体验更好）
 */
export class DateUtil {
  static formatDate(year: number, month: number, day: number): string {
    const m = month < 10 ? `0${month}` : `${month}`;
    const d = day < 10 ? `0${day}` : `${day}`;
    return `${year}-${m}-${d}`;
  }

  static formatFromDate(date: Date): string {
    return DateUtil.formatDate(date.getFullYear(), date.getMonth() + 1, date.getDate());
  }

  static parseDateString(dateStr: string): Date {
    const now = new Date();
    if (dateStr.length >= 10) {
      const parts = dateStr.split('-');
      if (parts.length === 3) {
        const y = parseInt(parts[0]);
        const m = parseInt(parts[1]) - 1;
        const d = parseInt(parts[2]);
        if (!isNaN(y) && !isNaN(m) && !isNaN(d)) {
          return new Date(y, m, d);
        }
      }
    }
    return new Date(now.getFullYear(), now.getMonth(), now.getDate());
  }

  static showDatePicker(current: string, onPick: (dateStr: string) => void): void {
    const now = new Date();
    const selected = current.length >= 10 ? DateUtil.parseDateString(current) : new Date(now.getFullYear(), now.getMonth(), now.getDate());

    CalendarPickerDialog.show({
      selected: selected,
      onAccept: (value: Date) => {
        onPick(DateUtil.formatFromDate(value));
      }
    });
  }
}
