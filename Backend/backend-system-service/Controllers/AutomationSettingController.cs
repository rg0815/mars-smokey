// using Microsoft.AspNetCore.Mvc;
// using backend_system_service.Entities;
// using backend_system_service.Repositories;
// using Microsoft.AspNetCore.Authorization;
//
// namespace backend_system_service.Controllers
// {
//     [Route("api/[controller]")]
//     [ApiController, Authorize]
//     public class AutomationSettingController : ControllerBase
//     {
//         private readonly IGenericRepository<AutomationSetting> _automationSettingRepository;
//
//         public AutomationSettingController(IGenericRepository<AutomationSetting> automationSettingRepository)
//         {
//             _automationSettingRepository = automationSettingRepository;
//         }
//
//         // GET: api/AutomationSetting
//         [HttpGet]
//         public async Task<ActionResult<IEnumerable<AutomationSetting>>> GetAutomationSettings()
//         {
//             var model = _automationSettingRepository.GetAll().ToList();
//             return Ok(model);
//         }
//
//         // GET: api/AutomationSetting/5
//         [HttpGet("{id}")]
//         public async Task<ActionResult<AutomationSetting>> GetAutomationSetting(Guid id)
//         {
//             var automationSetting = _automationSettingRepository.GetById(id);
//
//             if (automationSetting == null)
//             {
//                 return NotFound();
//             }
//
//             return Ok(automationSetting);
//         }
//
//         // PUT: api/AutomationSetting/5
//         // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
//         [HttpPut("{id}")]
//         public async Task<IActionResult> PutAutomationSetting(Guid id, AutomationSetting automationSetting)
//         {
//             if (_automationSettingRepository.GetById(id) == null)
//             {
//                 return NotFound();
//             }
//
//             _automationSettingRepository.Update(automationSetting);
//             return Ok(GetAutomationSetting(automationSetting.Id));
//         }
//
//         // POST: api/AutomationSetting
//         // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
//         [HttpPost]
//         public async Task<ActionResult<AutomationSetting>> PostAutomationSetting(AutomationSetting automationSetting)
//         {
//             if (_automationSettingRepository.GetByCondition(x => x.Id == automationSetting.Id) != null)
//             {
//                 return BadRequest();
//             }
//
//             _automationSettingRepository.Insert(automationSetting);
//             return CreatedAtAction("GetAutomationSetting", new {id = automationSetting.Id}, automationSetting);
//         }
//
//         // DELETE: api/AutomationSetting/5
//         [HttpDelete("{id}")]
//         public async Task<IActionResult> DeleteAutomationSetting(Guid id)
//         {
//             var automationSetting = _automationSettingRepository.GetById(id);
//             if (automationSetting == null)
//             {
//                 return NotFound();
//             }
//
//             _automationSettingRepository.Delete(automationSetting);
//             return NoContent();
//         }
//     }
// }