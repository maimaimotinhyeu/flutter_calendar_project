package com.example.calendar_project

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class TetWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.tet_widget_layout).apply {
                val titleText = widgetData.getString("tet_title", "Tết 2027")
                val daysText = widgetData.getString("tet_days", "00")
                val hoursText = widgetData.getString("tet_hours", "00")
                val minsText = widgetData.getString("tet_mins", "00")
                val secsText = widgetData.getString("tet_secs", "00")
                val upcomingText = widgetData.getString("upcoming_event", "Năm Con Dê")
                
                // Set the premium traditional background
                val bgResId = R.drawable.widget_background_do

                setInt(R.id.widget_root, "setBackgroundResource", bgResId)
                setTextViewText(R.id.widget_title, titleText)
                setTextViewText(R.id.widget_days, daysText)
                setTextViewText(R.id.widget_hours, hoursText)
                setTextViewText(R.id.widget_mins, minsText)
                setTextViewText(R.id.widget_secs, secsText)
                setTextViewText(R.id.widget_upcoming, upcomingText)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
