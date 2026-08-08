"use client";

import React from 'react';
import Icon from '@/components/Icon';

const features = [
  { icon: 'users', title: 'Real-time Resident Management', desc: 'Track residents, visitors, and requests instantly.' },
  { icon: 'calendar', title: 'Facility & Booking Control', desc: 'Manage amenities, slots, and community spaces.' },
  { icon: 'bar-chart-2', title: 'Smart Analytics Dashboard', desc: 'Data-driven insights for every decision.' },
];

export default function AdminLoginScreen() {
  return (
    <div className="flex font-body bg-background" style={{ minHeight: '100vh' }}>

      {/* ── Left Panel ── */}
      <div
        className="flex flex-col justify-between px-16 py-14"
        style={{
          width: '55%',
          background: 'linear-gradient(145deg, #0F172A 0%, #1E3A8A 60%, #1e40af 100%)',
          minHeight: '100vh',
        }}
      >
        {/* Logo / Brand */}
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: 'rgba(255,255,255,0.15)' }}>
            <Icon i="building-2" size={22} className="text-primary-foreground" />
          </div>
          <span className="text-lg font-semibold text-primary-foreground font-body">Community Hub</span>
        </div>

        {/* Centre: hero text + illustration area */}
        <div className="flex flex-col gap-8">
          {/* Abstract geometric background decoration */}
          <div className="relative mb-2">
            {/* Big geometric circles */}
            <div className="absolute -top-16 -left-10 w-72 h-72 rounded-full opacity-10" style={{ background: 'radial-gradient(circle, #93c5fd, transparent 70%)' }} />
            <div className="absolute top-10 right-0 w-48 h-48 rounded-full opacity-10" style={{ background: 'radial-gradient(circle, #6ee7b7, transparent 70%)' }} />

            <div className="relative z-10">
              <p className="text-5xl font-semibold text-primary-foreground font-body leading-tight mb-3">Maple Heights</p>
              <p className="text-5xl font-semibold font-body leading-tight mb-4" style={{ color: '#93c5fd' }}>Residency</p>
              <p className="text-lg font-body font-normal" style={{ color: 'rgba(255,255,255,0.60)' }}>Administration Portal</p>
            </div>
          </div>

          {/* Feature highlights */}
          <div className="flex flex-col gap-4">
            {features.map((f, i) => (
              <div key={i} className="flex items-start gap-4">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: 'rgba(255,255,255,0.10)' }}>
                  <Icon i={f.icon} size={18} className="text-primary-foreground" />
                </div>
                <div>
                  <p className="text-sm font-semibold text-primary-foreground">{f.title}</p>
                  <p className="text-xs mt-0.5" style={{ color: 'rgba(255,255,255,0.55)' }}>{f.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Bottom tag */}
        <p className="text-xs font-body" style={{ color: 'rgba(255,255,255,0.35)' }}>© 2024 CommunityHub. All rights reserved.</p>
      </div>

      {/* ── Right Panel ── */}
      <div
        className="flex flex-col justify-center items-center px-16 bg-background"
        style={{ width: '45%', minHeight: '100vh' }}
      >
        <form 
          className="w-full" 
          style={{ maxWidth: '400px' }}
          onSubmit={(e) => {
            e.preventDefault();
            alert("Sign in submitted!");
          }}
        >

          {/* Heading */}
          <div className="mb-8">
            <p className="text-2xl font-semibold text-foreground mb-1">Welcome Back, Admin 👋</p>
            <p className="text-sm text-muted-foreground">Sign in to manage Maple Heights Residency</p>
          </div>

          {/* Email */}
          <div className="mb-4">
            <label className="block text-xs font-medium text-muted-foreground mb-1.5">Email Address</label>
            <div className="flex items-center gap-2.5 bg-input border border-border rounded-lg px-3.5 py-3" style={{ boxShadow: '0 0 0 0px #2563eb' }}>
              <Icon i="mail" size={16} className="text-muted-foreground flex-shrink-0" />
              <input 
                type="email" 
                placeholder="admin@mapleheights.in" 
                className="text-sm flex-1"
                style={{ background: 'transparent', border: 'none', outline: 'none', color: 'var(--color-foreground)' }}
                required
              />
            </div>
          </div>

          {/* Password */}
          <div className="mb-2">
            <label className="block text-xs font-medium text-muted-foreground mb-1.5">Password</label>
            <div className="flex items-center gap-2.5 bg-input border border-border rounded-lg px-3.5 py-3">
              <Icon i="lock" size={16} className="text-muted-foreground flex-shrink-0" />
              <input 
                type="password" 
                placeholder="••••••••••••" 
                className="text-sm flex-1"
                style={{ background: 'transparent', border: 'none', outline: 'none', color: 'var(--color-foreground)' }}
                required
              />
              <Icon i="eye" size={16} className="text-muted-foreground flex-shrink-0 cursor-pointer" />
            </div>
          </div>

          {/* Forgot password */}
          <div className="flex justify-end mb-6">
            <a className="text-xs font-medium text-primary cursor-pointer">Forgot Password?</a>
          </div>

          {/* Sign In button */}
          <button
            className="w-full text-primary-foreground font-semibold text-sm py-3.5 rounded-lg flex items-center justify-center gap-2"
            style={{
              background: 'linear-gradient(90deg, #2563eb 0%, #1d4ed8 100%)',
              boxShadow: '0 4px 16px 0 rgba(37,99,235,0.35)',
              border: 'none',
              cursor: 'pointer',
            }}
          >
            <Icon i="log-in" size={17} />
            Sign In to Admin Portal
          </button>

          {/* Divider */}
          <div className="flex items-center gap-3 my-6">
            <div className="flex-1 h-px bg-border" />
            <span className="text-xs text-muted-foreground">secure access</span>
            <div className="flex-1 h-px bg-border" />
          </div>

          {/* Trust badges */}
          <div className="flex justify-center gap-5 mb-10">
            <div className="flex items-center gap-1.5">
              <Icon i="shield-check" size={14} className="text-accent" />
              <span className="text-xs text-muted-foreground">256-bit SSL</span>
            </div>
            <div className="flex items-center gap-1.5">
              <Icon i="lock" size={14} className="text-accent" />
              <span className="text-xs text-muted-foreground">2FA Enabled</span>
            </div>
            <div className="flex items-center gap-1.5">
              <Icon i="eye-off" size={14} className="text-accent" />
              <span className="text-xs text-muted-foreground">Admin-only Access</span>
            </div>
          </div>

          {/* Version */}
          <p className="text-center text-xs text-muted-foreground">v1.0.0 · Maple Heights</p>
        </form>
      </div>

    </div>
  );
}
