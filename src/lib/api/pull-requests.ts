/**
 * Pull Request API Client
 */

import { apiCall } from "../api-client";

export interface CreatePRRequest {
  project_id: string;
  generation_id: string;
  base_branch?: string;
}

export interface CreatePRResponse {
  pr_number: number;
  pr_url: string;
  branch: string;
  validation_warnings: string[];
}

export interface PRStatus {
  pr_number: number;
  pr_url: string;
  state: "open" | "closed";
  merged: boolean;
  mergeable: boolean | null;
  created_at: string;
  updated_at: string;
}

export const pullRequestsApi = {
  /**
   * Create a GitHub PR with generated infrastructure files
   * Includes retry logic for network errors
   */
  async createPR(request: CreatePRRequest): Promise<CreatePRResponse> {
    const maxRetries = 3;
    let lastError: Error | null = null;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        const response = await apiCall("/pull-requests/create", {
          method: "POST",
          body: JSON.stringify(request),
        });

        if (!response.ok) {
          const error = await response
            .json()
            .catch(() => ({ detail: "Failed to create PR" }));
          throw new Error(error.detail || "Failed to create PR");
        }

        return response.json();
      } catch (error) {
        lastError = error instanceof Error ? error : new Error("Unknown error");

        // Check if it's a network error that might be transient
        const isNetworkError =
          lastError.message.includes("network") ||
          lastError.message.includes("fetch") ||
          lastError.message.includes("ERR_NETWORK");

        // If it's the last attempt or not a network error, throw immediately
        if (attempt === maxRetries - 1 || !isNetworkError) {
          throw lastError;
        }

        // Wait before retrying (exponential backoff: 1s, 2s, 4s)
        await new Promise((resolve) =>
          setTimeout(resolve, Math.pow(2, attempt) * 1000)
        );
        console.log(
          `Retrying PR creation (attempt ${attempt + 2}/${maxRetries})...`
        );
      }
    }

    throw lastError || new Error("Failed to create PR");
  },

  /**
   * Get PR status for a project
   */
  async getPRStatus(projectId: string): Promise<PRStatus> {
    const response = await apiCall(`/pull-requests/${projectId}/status`, {
      method: "GET",
    });

    if (!response.ok) {
      const error = await response
        .json()
        .catch(() => ({ detail: "Failed to get PR status" }));
      throw new Error(error.detail || "Failed to get PR status");
    }

    return response.json();
  },
};
