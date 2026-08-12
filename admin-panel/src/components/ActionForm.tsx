'use client'

import React, { useState } from 'react';

type ActionResponse = { error?: string, success?: boolean } | void;

export default function ActionForm({ 
  action, 
  children, 
  className 
}: { 
  action: (formData: FormData) => Promise<ActionResponse>;
  children: React.ReactNode;
  className?: string;
}) {
  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    try {
      const result = await action(formData);
      if (result && result.error) {
        alert(`Error: ${result.error}`);
      }
    } catch (err: any) {
      alert(`Error: ${err.message || 'An unexpected error occurred'}`);
    }
  };

  return (
    <form onSubmit={handleSubmit} className={className}>
      {children}
    </form>
  );
}
