using System.Linq.Expressions;
using Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace backend_user_service.Repository;

public class UserInvitationRepository : IUserInvitationRepository
{
    private readonly UsersContext _context;
    private readonly DbSet<UserInvitation> _dbSet;

    public UserInvitationRepository(UsersContext context)
    {
        _context = context;
        _dbSet = _context.Set<UserInvitation>();
    }

    public IEnumerable<UserInvitation> GetAll()
    {
        return _dbSet.ToList();
    }

    public IEnumerable<UserInvitation> GetAllByCondition(Expression<Func<UserInvitation, bool>> predicate)
    {
        return _dbSet.Where(predicate).ToList();
    }

    public UserInvitation? GetByCondition(Expression<Func<UserInvitation, bool>> predicate)
    {
        return _dbSet.FirstOrDefault(predicate);
    }

    public void Insert(UserInvitation entity)
    {
        entity.IsAccepted = false;
        _dbSet.Add(entity);
        _context.SaveChanges();
    }

    public void Update(UserInvitation entity)
    {
        _dbSet.Attach(entity);
        _context.Entry(entity).State = EntityState.Modified;
        _context.SaveChanges();
    }

    public void Accept(UserInvitation entity)
    {
        entity.IsAccepted = true;
        entity.AcceptedDate = DateTime.Now.ToUniversalTime();
        _dbSet.Attach(entity);
        _context.Entry(entity).State = EntityState.Modified;
        _context.SaveChanges();
    }

    public void Delete(UserInvitation entity)
    {
        entity.IsDeleted = true;
        _dbSet.Attach(entity);
        _context.Entry(entity).State = EntityState.Modified;
        _context.SaveChanges();
    }
}

public interface IUserInvitationRepository
{
    IEnumerable<UserInvitation> GetAll();
    IEnumerable<UserInvitation> GetAllByCondition(Expression<Func<UserInvitation, bool>> predicate);
    // UserInvitation? GetById(Guid id);
    UserInvitation? GetByCondition(Expression<Func<UserInvitation, bool>> predicate);
    void Insert(UserInvitation entity);
    void Update(UserInvitation entity);
    // void Delete(IUserInvitationRepository entity);
    // void Delete(Guid id);
    // void Save();
}