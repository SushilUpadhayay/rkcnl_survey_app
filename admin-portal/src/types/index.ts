export type Role = 'Admin' | 'FieldStaff';
export type UserStatus = 'Pending' | 'Approved' | 'Rejected';

export type SurveyStatus = 'Draft' | 'Active' | 'Closed';

export interface User {
  id: string;
  fullName: string;
  email: string;
  gender?: string | null;
  dateOfBirth?: string | null;
  phone?: string | null;
  location?: string | null;
  role: Role;
  status: UserStatus;
  isActive: boolean;
  isDeleted: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Category {
  id: string;
  name: string;
  description?: string | null;
  createdById?: string | null;
  updatedById?: string | null;
  createdAt: string;
  updatedAt: string;
  _count?: {
    surveys: number;
  };
}

export interface QuestionOption {
  value: string;
  label: string;
}

export type QuestionType =
  | 'Single Choice'
  | 'Multi Choice'
  | 'Rating Scale'
  | 'Ranking'
  | 'Matrix/Grid'
  | 'Open End'
  | 'Choice with Free Writing'
  | 'Choice with Additional Option'
  | 'Pickup'
  | 'Pickup and Rank';

export interface Question {
  id: string;
  type: QuestionType;
  text: string;
  required: boolean;
  options?: string[] | QuestionOption[];
  // For Grid/Matrix
  rows?: string[];
  columns?: string[];
  // For Rating
  minRating?: number;
  maxRating?: number;
  minLabel?: string;
  maxLabel?: string;
  // Other potential props for ranking/pickup
  maxChoices?: number;
}

export interface Survey {
  id: string;
  title: string;
  description?: string | null;
  status: SurveyStatus;
  isDeleted: boolean;
  questions: Question[];
  categoryId?: string | null;
  category?: Category | null;
  createdById: string;
  createdBy?: User | null;
  updatedById?: string | null;
  updatedBy?: User | null;
  createdAt: string;
  updatedAt: string;
  _count?: {
    responses: number;
    assignments: number;
  };
}

export interface SurveyAssignment {
  id: string;
  surveyId: string;
  userId: string;
  survey?: Survey;
  user?: User;
  createdAt: string;
  updatedAt: string;
}

export interface Answer {
  questionId: string;
  questionText: string;
  value: any; // Can be string, string[], number, grid answers, etc.
}

export interface Response {
  id: string;
  deviceTimestamp: string;
  answers: Answer[];
  customQuestions?: any[] | null;
  personalNotes?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  photos: string[]; // URLs or base64
  surveyId: string;
  survey?: Survey;
  submittedById: string;
  submittedBy?: User;
  createdAt: string;
  updatedAt: string;
}

export interface DashboardStats {
  totalUsers: number;
  activeUsers: number;
  totalSurveys: number;
  activeSurveys: number;
  totalResponses: number;
}
