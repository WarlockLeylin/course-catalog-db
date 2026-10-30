\## Constraint violation log



Commands were run with `\\set VERBOSITY verbose`.



| # | What we violate | SQLSTATE | Constraint | API response |

|---|-----------------|----------|------------|--------------|

| 1 | NULL in courses.title | 23502 | `column "title"` (NOT NULL) | 422 Unprocessable Entity |

| 2 | courses.credits = 0 | 23514 | `courses\_credits\_check` | 422 Unprocessable Entity |

| 3 | courses.likes = -1 | 23514 | `courses\_likes\_check` | 500 Internal Server Error (Application bug) |

| 4 | a one-letter student name | 23514 | `students\_name\_check` | 422 Unprocessable Entity |

| 5 | a duplicate student email | 23505 | `students\_email\_key` | 409 Conflict |

| 6 | a duplicate course id | 23505 | `courses\_pkey` | 409 Conflict |

| 7 | a repeated enrollment in a course | 23505 | `enrollments\_course\_id\_student\_id\_key` | 409 Conflict |

| 8 | enrolling in a nonexistent course | 23503 | `enrollments\_course\_id\_fkey` | 404 Not Found |

| 9 | enrolling a nonexistent student | 23503 | `enrollments\_student\_id\_fkey` | 404 Not Found (or 422) |

| 10 | deleting a course with enrollments | 23001 | `enrollments\_course\_id\_fkey` | 409 Conflict |

| 11 | deleting a student (cascade delete) | — | `enrollments\_student\_id\_fkey` (CASCADE) | 204 No Content (Cascaded enrollments count: 6 → 3, restored to 6 after ROLLBACK) |



\### Why check constraints in the database if Pydantic already checks them in code?

> Pydantic validates incoming user requests at the API application level. However, the database can be accessed and modified by other services, background jobs, raw SQL scripts, or database administrators directly. Enforcing constraints at the database level guarantees data integrity universally, regardless of the entry point.

