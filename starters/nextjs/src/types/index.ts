// Standard API response envelope
export type ApiResponse<T> = {
  success: true;
  data: T;
} | {
  success: false;
  error: {
    message: string;
    code?: string;
  };
};

// Paginated response envelope
export type PaginatedResponse<T> = {
  success: true;
  data: T[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    totalPages: number;
  };
} | {
  success: false;
  error: {
    message: string;
    code?: string;
  };
};

// Generic role enum — customise for your project
export type UserRole = 'admin' | 'user';

// Generic status enum — customise for your project
export type UserStatus = 'active' | 'suspended' | 'deleted';

// Authenticated user context resolved by get-auth.ts
export type AuthUser = {
  id: string; // Supabase Auth user UUID
  email: string;
  name: string | null;
  role: UserRole;
  status: UserStatus;
};

// Pagination query params
export type PaginationParams = {
  page: number;
  pageSize: number;
};
