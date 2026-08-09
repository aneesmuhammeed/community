'use client';

import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from 'recharts';
import styles from './dashboard.module.css';

interface DashboardChartsProps {
  collectionData: any[];
  facilityData: any[];
}

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#a288e3', '#ff6b6b'];

export default function DashboardCharts({ collectionData, facilityData }: DashboardChartsProps) {
  return (
    <div className={styles.chartsGrid}>
      <div className={styles.chartCard}>
        <div className={styles.chartHeader}>
          <div>
            <h3>Monthly Maintenance Collection</h3>
            <p>Paid vs Overdue — FY 2024</p>
          </div>
        </div>
        <div className={styles.chartPlaceholder} style={{ background: 'transparent' }}>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={collectionData} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#eee" />
              <XAxis dataKey="month" axisLine={false} tickLine={false} />
              <YAxis axisLine={false} tickLine={false} tickFormatter={(val) => `₹${val / 1000}k`} />
              <Tooltip cursor={{ fill: 'transparent' }} />
              <Legend iconType="circle" />
              <Line type="monotone" dataKey="paid" name="Paid" stroke="#3b82f6" strokeWidth={3} dot={{ r: 4 }} activeDot={{ r: 6 }} />
              <Line type="monotone" dataKey="overdue" name="Overdue" stroke="#f97316" strokeWidth={3} dot={{ r: 4 }} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className={styles.pieCard}>
        <div className={styles.chartHeader}>
          <div>
            <h3>Facility Usage</h3>
            <p>By booking count</p>
          </div>
        </div>
        <div className={styles.chartPlaceholder} style={{ background: 'transparent', display: 'flex', justifyContent: 'center' }}>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={facilityData}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={80}
                paddingAngle={5}
                dataKey="value"
                nameKey="name"
                label={({ name, percent }) => `${name} ${((percent || 0) * 100).toFixed(0)}%`}
              >
                {facilityData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}
