import React from 'react';
import Icon from '@/components/Icon';
import UserAvatar from '@/components/UserAvatar';

export default function ResidentDetailDrawer() {
  return (
    <div className="bg-background border-l border-border flex flex-col" style={{ width: '320px', minHeight: '100%' }}>
      {/* Header */}
      <div className="px-5 py-4 border-b border-border flex items-center justify-between">
        <p className="text-sm font-semibold text-foreground font-body">Resident Profile</p>
        <button className="w-7 h-7 rounded-lg bg-muted flex items-center justify-center border-none cursor-pointer">
          <Icon i="x" size={15} className="text-muted-foreground" />
        </button>
      </div>

      {/* Profile top */}
      <div className="px-5 py-5 flex flex-col items-center text-center border-b border-border">
        <UserAvatar gender="male" heritage="South Asian" ageGroup="35-50" index={2} className="w-16 h-16 rounded-full mb-3" />
        <p className="text-base font-semibold text-foreground font-body">Rajesh Sharma</p>
        <p className="text-xs text-muted-foreground font-body mt-0.5">Block C · Apartment 301</p>
        <div className="flex items-center gap-2 mt-2">
          <span className="bg-secondary text-secondary-foreground text-xs font-medium font-body px-2 py-0.5 rounded-md">Owner</span>
          <span className="bg-accent-soft text-accent text-xs font-medium font-body px-2 py-0.5 rounded-md">Active</span>
        </div>
      </div>

      {/* Quick actions */}
      <div className="px-5 py-4 border-b border-border flex gap-2">
        <button className="flex-1 flex flex-col items-center gap-1 py-2.5 bg-secondary rounded-lg border-none cursor-pointer">
          <Icon i="message-square" size={16} className="text-primary" />
          <span className="text-xs font-medium text-primary font-body">Message</span>
        </button>
        <button className="flex-1 flex flex-col items-center gap-1 py-2.5 bg-muted rounded-lg border-none cursor-pointer">
          <Icon i="credit-card" size={16} className="text-muted-foreground" />
          <span className="text-xs font-medium text-muted-foreground font-body">Bills</span>
        </button>
        <button className="flex-1 flex flex-col items-center gap-1 py-2.5 bg-muted rounded-lg border-none cursor-pointer">
          <Icon i="message-circle" size={16} className="text-muted-foreground" />
          <span className="text-xs font-medium text-muted-foreground font-body">Complaints</span>
        </button>
      </div>

      {/* Contact Info */}
      <div className="px-5 py-4 border-b border-border flex flex-col gap-2.5">
        <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wide">Contact</p>
        <div className="flex items-center gap-2.5">
          <Icon i="phone" size={14} className="text-muted-foreground flex-shrink-0" />
          <span className="text-sm text-foreground font-body">+91 98765 43210</span>
        </div>
        <div className="flex items-center gap-2.5">
          <Icon i="mail" size={14} className="text-muted-foreground flex-shrink-0" />
          <span className="text-sm text-foreground font-body">rajesh.sharma@gmail.com</span>
        </div>
        <div className="flex items-center gap-2.5">
          <Icon i="calendar" size={14} className="text-muted-foreground flex-shrink-0" />
          <span className="text-sm text-foreground font-body">Moved in: Jan 12, 2020</span>
        </div>
      </div>

      {/* Family Members */}
      <div className="px-5 py-4 border-b border-border flex flex-col gap-2.5">
        <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wide">Family Members</p>
        {[
          { name: 'Priya Sharma', rel: 'Spouse', gender: 'female', idx: 3 },
          { name: 'Aryan Sharma', rel: 'Son', gender: 'male', idx: 5 },
        ].map((m, i) => (
          <div key={i} className="flex items-center gap-2.5">
            <UserAvatar gender={m.gender} heritage="South Asian" ageGroup="25-35" index={m.idx} className="w-7 h-7 rounded-full flex-shrink-0" />
            <div>
              <p className="text-xs font-medium text-foreground font-body">{m.name}</p>
              <p className="text-xs text-muted-foreground font-body">{m.rel}</p>
            </div>
          </div>
        ))}
      </div>

      {/* Vehicles */}
      <div className="px-5 py-4 border-b border-border flex flex-col gap-2">
        <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wide">Registered Vehicles</p>
        {['MH02 AB 1234 · White Swift', 'MH02 CD 5678 · Black Creta'].map((v, i) => (
          <div key={i} className="flex items-center gap-2.5">
            <Icon i="car" size={14} className="text-muted-foreground flex-shrink-0" />
            <span className="text-xs text-foreground font-body">{v}</span>
          </div>
        ))}
      </div>

      {/* Billing Summary */}
      <div className="px-5 py-4 flex flex-col gap-2">
        <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wide">Billing Summary</p>
        <div className="flex items-center justify-between">
          <span className="text-xs text-muted-foreground font-body">Last Payment</span>
          <span className="text-xs font-medium text-accent font-body">₹4,500 · Nov 1</span>
        </div>
        <div className="flex items-center justify-between">
          <span className="text-xs text-muted-foreground font-body">Pending Dues</span>
          <span className="text-xs font-medium text-danger font-body">₹0</span>
        </div>
        <div className="flex items-center justify-between">
          <span className="text-xs text-muted-foreground font-body">Next Due</span>
          <span className="text-xs font-medium text-foreground font-body">Dec 1, 2024</span>
        </div>
      </div>
    </div>
  );
}
