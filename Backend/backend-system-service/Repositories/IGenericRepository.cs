using System.Linq.Expressions;

namespace backend_system_service.Repositories;

public interface IGenericRepository<T> where T : class
{
    IEnumerable<T> GetAll();
    IEnumerable<T> GetAllByCondition(Expression<Func<T, bool>> predicate);
    T? GetById(Guid id);
    T? GetByCondition(Expression<Func<T, bool>> predicate);
    void Insert(T entity);
    void Update(T entity);
    void Delete(T entity);
    void Delete(Guid id);
    void Save();

}