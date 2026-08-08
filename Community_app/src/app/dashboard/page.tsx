import React from 'react';
import Icon from '@/components/Icon';
import AdminTopNav from '@/components/AdminTopNav';
import AdminSidebar from '@/components/AdminSidebar';
import KPICard from '@/components/KPICard';
import MaintenanceLineChart from '@/components/MaintenanceLineChart';
import FacilityDonutChart from '@/components/FacilityDonutChart';
import RecentComplaintsPanel from '@/components/RecentComplaintsPanel';
import VisitorApprovalsPanel from '@/components/VisitorApprovalsPanel';

export default function AdminDashboardScreen() {
  return (
    <div className="bg-input font-body flex flex-col" style={{ minHeight: '100vh' }}>
      {/* Top Nav */}
      <AdminTopNav />

      {/* Body: Sidebar + Main */}
      <div className="flex flex-1">
        {/* Sidebar */}
        <AdminSidebar />

        {/* Main Content */}
        <div className="flex-1 px-8 py-7 flex flex-col gap-6 min-w-0">

          {/* Page heading */}
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xl font-semibold text-foreground font-body">Dashboard Overview</p>
              <p className="text-sm text-muted-foreground font-body mt-0.5">Welcome back, Super Admin — here's what's happening today.</p>
            </div>
            <div className="flex items-center gap-2 text-xs text-muted-foreground font-body bg-card border border-border rounded-lg px-3 py-2" style={{ boxShadow: '0 1px 4px 0 rgba(30,40,80,0.05)' }}>
              <Icon i="calendar" size={14} className="text-muted-foreground" />
              Nov 28, 2024 · 9:41 AM
            </div>
          </div>

          {/* KPI Cards */}
          <div className="flex gap-4 flex-wrap">
            <KPICard
              title="Total Residents"
              value="248"
              badge="+4 this month"
              badgeColor="green"
              icon="users"
              trendIcon="trending-up"
            />
            <KPICard
              title="Active Complaints"
              value="12"
              badge="3 urgent"
              badgeColor="red"
              icon="message-circle"
              trendIcon="alert-triangle"
            />
            <KPICard
              title="Today's Visitors"
              value="34"
              badge="5 pending"
              badgeColor="blue"
              icon="shield-check"
              trendIcon="users"
            />
            <KPICard
              title="Pending Dues"
              value="₹1,24,500"
              badge="12 unpaid"
              badgeColor="orange"
              icon="credit-card"
              trendIcon="trending-down"
            />
          </div>

          {/* Charts Row */}
          <div className="flex gap-5 flex-wrap">
            <div style={{ flex: '1 1 60%' }}>
              <MaintenanceLineChart />
            </div>
            <div style={{ flex: '1 1 35%' }}>
              <FacilityDonutChart />
            </div>
          </div>

          {/* Bottom Row */}
          <div className="flex gap-5 flex-wrap">
            <div style={{ flex: '1 1 48%' }}>
              <RecentComplaintsPanel />
            </div>
            <div style={{ flex: '1 1 48%' }}>
              <VisitorApprovalsPanel />
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
