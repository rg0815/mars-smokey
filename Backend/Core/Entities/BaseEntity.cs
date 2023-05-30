﻿namespace Core.Entities;

public abstract class BaseEntity
{
    public string? Name { get; set; }
    public string? Description { get; set; }
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}