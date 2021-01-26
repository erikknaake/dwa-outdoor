alias OutdoorDwa.UserContext.User
alias OutdoorDwa.TeamContext.Team
alias OutdoorDwa.RivalContext.Rival
alias OutdoorDwa.TrackContext.Track
alias OutdoorDwa.EditionContext.Edition
alias OutdoorDwa.EditionUserRoleContext.EditionUserRole
alias OutdoorDwa.TravelQuestionContext.TravelQuestion
alias OutdoorDwa.PracticalTaskSubmissionContext.PracticalTaskSubmission
alias OutdoorDwa.PracticalTask_TeamContext.PracticalTask_Team
alias OutdoorDwa.PracticalTaskContext.PracticalTask
alias OutdoorDwa.TravelQuestioningContext.TravelQuestioning
alias OutdoorDwa.TravelQuestionAnswerContext.TravelQuestionAnswer
alias OutdoorDwa.TeamSettingContext.TeamSetting
alias OutdoorDwa.SettingContext.Setting
alias OutdoorDwa.ProjectContext.Project
alias OutdoorDwa.TeamProjectContext.TeamProject
alias OutdoorDwa.Repo
import Ecto.Query

Repo.delete_all(from e in PracticalTaskSubmission)
Repo.delete_all(from e in PracticalTask_Team)
Repo.delete_all(from e in PracticalTask)

Repo.delete_all(from e in TravelQuestionAnswer)
Repo.delete_all(from e in TravelQuestioning)
Repo.delete_all(from e in TravelQuestion)

Repo.delete_all(from e in TeamProject)
Repo.delete_all(from e in Project)

Repo.delete_all(from e in Track)

Repo.delete_all(from e in Rival)

Repo.delete_all(from e in TeamSetting)
Repo.delete_all(from e in Setting)
Repo.delete_all(from e in Team)
Repo.delete_all(from e in EditionUserRole)
Repo.delete_all(from e in User)

Repo.delete_all(from e in Edition)
