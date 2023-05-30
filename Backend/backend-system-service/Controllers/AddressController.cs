using Microsoft.AspNetCore.Mvc;
using backend_system_service.Helper;
using backend_system_service.Models;
using backend_system_service.Repositories;
using Core.Entities;
using Microsoft.AspNetCore.Authorization;

namespace backend_system_service.Controllers
{
    [Route("api/[controller]")]
    [ApiController, Authorize]
    public class AddressController : BaseController
    {
        private readonly IGenericRepository<Address> _addressRepository;

        public AddressController(IGenericRepository<Address> addressRepository)
        {
            _addressRepository = addressRepository;
        }

        // GET: api/Address/5
        [HttpGet("{id:guid}")]
        public ActionResult<Address> GetAddress(Guid id)
        {
            if (Roles == null) return Forbid();

            var address = _addressRepository.GetById(id);

            if (address == null)
            {
                return NotFound();
            }

            if (!PermissionHelper.CheckPermission(Roles, Permission.Read, address))
            {
                return Forbid();
            }

            return Ok(address);
        }

        // PUT: api/Address/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id:guid}")]
        public ActionResult PutAddress(Guid id, UpdateAddressRequest address)
        {
            if (Roles == null) return Forbid();
            var existingAddress = _addressRepository.GetById(id);
            if (existingAddress == null)
            {
                return NotFound();
            }

            existingAddress.Street = address.Street;
            existingAddress.City = address.City;
            existingAddress.ZipCode = address.ZipCode;
            existingAddress.Country = address.Country;

            if (!PermissionHelper.CheckPermission(Roles, Permission.Update, existingAddress))
            {
                return Forbid();
            }

            _addressRepository.Update(existingAddress);
            return Ok(existingAddress);
        }

        // POST: api/Address
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public ActionResult<Address> PostAddress(Address address)
        {
            if (Roles == null) return Forbid();
            if (!PermissionHelper.CheckPermission(Roles, Permission.Create, address))
            {
                return Forbid();
            }

            if (_addressRepository.GetByCondition(x => x.Id == address.Id) != null)
            {
                return BadRequest();
            }

            _addressRepository.Insert(address);
            return CreatedAtAction("GetAddress", new {id = address.Id}, address);
        }
    }
}