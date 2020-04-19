package com.tp.common.util

import java.time.{Instant, ZoneId, ZonedDateTime}
import java.time.temporal.ChronoUnit

object DataTimeTruncating extends DataTimeTruncating(ZoneId.of("Asia/Shanghai"))

class DataTimeTruncating(defaultZoneId: ZoneId) {

  implicit class TimestampTruncatingImplicit(l: Long) extends InstantTruncatingImplicit(Instant.ofEpochMilli(l))

  implicit class InstantTruncatingImplicit(t: Instant) {

    def truncatedToYear(zoneId: ZoneId = defaultZoneId): Instant =
      t.atZone(zoneId)
        .withMonth(1)
        .withDayOfMonth(1)
        .withHour(0)
        .withMinute(0)
        .withSecond(0)
        .withNano(0)
        .toInstant

    def truncatedToMonth(zoneId: ZoneId = defaultZoneId): Instant =
      t.atZone(zoneId)
        .withDayOfMonth(1)
        .withHour(0)
        .withMinute(0)
        .withSecond(0)
        .withNano(0)
        .toInstant

    def truncatedToWeek(zoneId: ZoneId = defaultZoneId): Instant = {
      val d: ZonedDateTime = t.atZone(zoneId)
      val dayOfWeek        = d.getDayOfWeek.getValue
      d.minusDays(dayOfWeek).truncatedTo(ChronoUnit.DAYS).toInstant
    }

    def truncatedToDay(zoneId: ZoneId = defaultZoneId): Instant =
      t.atZone(zoneId).truncatedTo(ChronoUnit.DAYS).toInstant

    def truncatedToHour(zoneId: ZoneId = defaultZoneId): Instant =
      t.atZone(zoneId).truncatedTo(ChronoUnit.HOURS).toInstant

    def truncatedToMinute: Instant = t.truncatedTo(ChronoUnit.MINUTES)

    def truncatedToSecond: Instant = t.truncatedTo(ChronoUnit.SECONDS)

    def truncatedToMillisecond: Instant = t.truncatedTo(ChronoUnit.MILLIS)

  }
}
