defmodule OutdoorDwa.Seeder do
  alias OutdoorDwa.UserContext.User
  alias OutdoorDwa.TeamContext.Team
  alias OutdoorDwa.RivalContext.Rival
  alias OutdoorDwa.TrackContext.Track
  alias OutdoorDwa.EditionContext.Edition
  alias OutdoorDwa.EditionUserRoleContext.EditionUserRole
  alias OutdoorDwa.TravelQuestionContext.TravelQuestion
  alias OutdoorDwa.ProjectContext.Project
  alias OutdoorDwa.PracticalTaskSubmissionContext.PracticalTaskSubmission
  alias OutdoorDwa.PracticalTask_TeamContext
  alias OutdoorDwa.PracticalTaskContext.PracticalTask
  alias OutdoorDwa.TravelQuestioningContext.TravelQuestioning
  alias PracticalTask_TeamContext.PracticalTask_Team
  alias OutdoorDwa.TravelQuestionAnswerContext.TravelQuestionAnswer
  alias OutdoorDwa.SettingContext.Setting
  alias OutdoorDwa.TeamSettingContext.TeamSetting
  alias OutdoorDwa.Repo

  def seed() do
    if length(OutdoorDwa.UserContext.list_users()) == 0 do
      user1 =
        %User{
          name: "Ikki",
          password_hash: "fsdfglkjhweruwf"
        }
        |> Repo.insert!()

      user2 =
        %User{
          name: "Walter",
          password_hash: "geghrthh"
        }
        |> Repo.insert!()

      user3 =
        %User{
          name: "Bram",
          password_hash: "dfdsfgeghrthh"
        }
        |> Repo.insert!()

      user4 =
        %User{
          name: "Jetske",
          password_hash: "dfdsafddsfgeghrthh"
        }
        |> Repo.insert!()

      user5 =
        %User{
          name: "Peter",
          password_hash: "asdasdasd"
        }
        |> Repo.insert!()

      user6 =
        %User{
          name: "Sjaak",
          password_hash: "56ghfghfgh"
        }
        |> Repo.insert!()

      user7 =
        %User{
          name: "Hendrik",
          password_hash: "sdiuhdsdfsdf"
        }
        |> Repo.insert!()

      user8 =
        %User{
          name: "Geert",
          password_hash: "asdasdzx4"
        }
        |> Repo.insert!()

      user9 =
        %User{
          name: "Erik",
          password_hash:
            "$pbkdf2-sha512$160000$JSh.e6nXqk9ldQ8lekV8MQ$6LPodsIwDnaqZ05U.cBvX78/gCGJGMTRq6G8GvdhHK.gRG0Cn/DkU8/SFdKDPNmeVei/4eqwHQyYvlbqjTv36A"
        }
        |> Repo.insert!()

      user10 =
        %User{
          name: "Maarten",
          password_hash:
            "$pbkdf2-sha512$160000$QtAp9p71QXNuvoseWtR3Xw$hZ9i45ZcvbsDsHHvxa2/rNVp5kaZ6MRPqtfAGCxv0sLLQmLnQKJyuyG012TFAn95AaVtFqUYyStOW5ndyE4Jug"
        }
        |> Repo.insert!()

      user11 =
        %User{
          name: "Julian",
          password_hash:
            "$pbkdf2-sha512$160000$rsDLO2bTxz8J7MkEYI21ww$lVSahdFV9JWLzUyusilmZWcqJYv4Nx2sdco5yqUkXuZ8xvGMieslp/qtUo/RDMXrkqtFnr2s/uKcbRia8LI5AQ"
        }
        |> Repo.insert!()

      user12 =
        %User{
          name: "Bonno",
          password_hash:
            "$pbkdf2-sha512$160000$V2YfoClEN86TqAwXHNVjBw$d/srCuw4KOQfq.ftjxm15IIjg.LMz.GeQpNLH6GpoT8YtXIpxkRYUs6g74pbQ2GLlrQfxsRFo4JLQs8.ACS9sg"
        }
        |> Repo.insert!()

      user13 =
        %User{
          name: "Dennis",
          password_hash:
            "$pbkdf2-sha512$160000$nosmc223ZjnmXK2h.AK0gQ$jgxST4/UwK5Pfv2mHQoGB0GKN5QhOgADcU7rQ3g1M5uc1ee9qsVmgWBTaTRcq8Mivic4tF1QlJOR1Ssvq6DrFA"
        }
        |> Repo.insert!()

      user14 =
        %User{
          name: "Bart",
          password_hash:
            "$pbkdf2-sha512$160000$GA1QV/t6EiYdOd4.L4pA7g$9a8UiR01uhntN/9PIvrYRBArpNkOaEcfmrBOad2zup/zbnIgB/PgBJlyvtDo/xbU9AdZc8bUHt4KZGURD..oPA"
        }
        |> Repo.insert!()

      user15 =
        %User{
          name: "Robert",
          password_hash:
            "$pbkdf2-sha512$160000$LFb/cGDgC5K3/Q8sNlPPrQ$41P2pVz2EOHTEhEpzpncG5ZiE.kd804Z9r/juDxanHIxd4NQA7OP9YJsmQTFEUflddpFAPqmtptGG9Egaxrcwg"
        }
        |> Repo.insert!()

      user16 =
        %User{
          name: "Ugur",
          password_hash:
            "$pbkdf2-sha512$160000$jSIwTFALmxZ/FFMwmysJQg$uYWpuNCuD705SVlPBVLQvo2FbbLoRoyeGhD.HiqLLOdIl/kw2GIxs9bYwPwlqQToJ62Igv1b8uWcCAS0rZF1NQ"
        }
        |> Repo.insert!()

      user17 =
        %User{
          name: "Douwe",
          password_hash:
            "$pbkdf2-sha512$160000$gvtXTYR82e9r5KnyCX5T4A$hEaROdZbLFKS3KGWgv2SlXWXrBQPfj3K1JXaNSwmGaIUuWueIf/rIJd0v0NqJr3xbFQBgWktkgScxyPwbkOPrg"
        }
        |> Repo.insert!()

      user17 =
        %User{
          name: "Luciano",
          password_hash:
            "$pbkdf2-sha512$160000$JSyMAsSnq9DHp1C5DCVbEg$ZhkKElOKIbv54UJ7aqsINgJ2E/W9q8PxeSVBuo0CqDHhL4e68mqjw0qcFQQw.bCWXoyNnOfP8rywiF.Fx8tkGA"
        }
        |> Repo.insert!()

      _user18 =
        %User{
          name: "admin",
          password_hash:
            "$pbkdf2-sha512$160000$1gDN4dhE.9TLCoDogDPjWg$.H/QwA2GogQ3Lb2gzCs8DgxAE25bpHGbe0ZdIeZL1nR4x6revb4Ed5T/xDxcRn694Yec.1ag4LNe2NZ8bXbMwQ",
          is_admin: true
        }
        |> Repo.insert!()

      edition1 =
        %Edition{
          start_datetime: ~U[2021-10-10 19:00:00Z],
          end_datetime: ~U[2021-10-10 23:59:59Z],
          is_open_for_registration: false
        }
        |> Repo.insert!()

      edition2 =
        %Edition{
          start_datetime: ~U[2021-01-01 19:00:00Z],
          end_datetime: ~U[2021-06-01 23:59:59Z],
          is_open_for_registration: true
        }
        |> Repo.insert!()

      team1 =
        %Team{
          password_hash: "fiuewgrf",
          group_size: 10,
          postalcode: "7203AJ",
          organisation_name: "Karel Doorman groep",
          city: "Zutphen",
          travel_credits: 10,
          travel_points: 4,
          number_of_broom_sweepers: 2,
          user: user1,
          edition: edition1,
          team_name: "Eerste Team"
        }
        |> Repo.insert!()

      team2 =
        %Team{
          password_hash: "fisfdwuewgrf",
          group_size: 5,
          postalcode: "7207AF",
          organisation_name: "Sint Joris",
          city: "Eefde",
          travel_credits: 2,
          travel_points: 1,
          number_of_broom_sweepers: 4,
          user: user2,
          edition: edition1,
          team_name: "Coole Team"
        }
        |> Repo.insert!()

      team3 =
        %Team{
          password_hash: "fifdsfsfdwuewgrf",
          group_size: 2,
          postalcode: "1234AF",
          organisation_name: "Zona",
          city: "Warnsveld",
          travel_credits: 2,
          travel_points: 1,
          number_of_broom_sweepers: 4,
          user: user12,
          edition: edition1,
          team_name: "Beste Team"
        }
        |> Repo.insert!()

      team4 =
        %Team{
          password_hash: "fasf32asa",
          group_size: 4,
          postalcode: "6835MV",
          organisation_name: "Peter Schoenmaat Groep",
          city: "Arnhem",
          travel_credits: 6,
          travel_points: 2,
          number_of_broom_sweepers: 3,
          user: user5,
          edition: edition2,
          team_name: "team amsterdam"
        }
        |> Repo.insert!()

      team5 =
        %Team{
          password_hash: "fisfdwuewgrf",
          group_size: 13,
          postalcode: "5830SD",
          organisation_name: "Scouting Groessen",
          city: "Groessen",
          travel_credits: 8,
          travel_points: 4,
          number_of_broom_sweepers: 1,
          user: user6,
          edition: edition2,
          team_name: "De Winnaar"
        }
        |> Repo.insert!()

      team6 =
        %Team{
          password_hash:
            "$pbkdf2-sha512$160000$JSh.e6nXqk9ldQ8lekV8MQ$6LPodsIwDnaqZ05U.cBvX78/gCGJGMTRq6G8GvdhHK.gRG0Cn/DkU8/SFdKDPNmeVei/4eqwHQyYvlbqjTv36A",
          group_size: 35,
          postalcode: "7531CW",
          organisation_name: "Scouting Team Nederland",
          city: "Winterswijk",
          travel_credits: 4,
          travel_points: 2,
          number_of_broom_sweepers: 5,
          user: user9,
          edition: edition2,
          team_name: "Team BEAST"
        }
        |> Repo.insert!()

      rival1 =
        %Rival{
          team: team1,
          rival: team2
        }
        |> Repo.insert!()

      rival4 =
        %Rival{
          team: team4,
          rival: team5
        }
        |> Repo.insert!()

      rival5 =
        %Rival{
          team: team5,
          rival: team4
        }
        |> Repo.insert!()

      rival6 =
        %Rival{
          team: team5,
          rival: team6
        }
        |> Repo.insert!()

      edition_user_role1 =
        %EditionUserRole{
          edition: edition1,
          user: user4,
          role: "Organisator"
        }
        |> Repo.insert!()

      edition_user_role2 =
        %EditionUserRole{
          edition: edition2,
          user: user10,
          role: "Organisator"
        }
        |> Repo.insert!()

      edition_user_role3 =
        %EditionUserRole{
          edition: edition2,
          user: user9,
          role: "TeamLeader"
        }
        |> Repo.insert!()

      edition_user_role4 =
        %EditionUserRole{
          edition: edition2,
          user: user12,
          role: "TeamLeader"
        }
        |> Repo.insert!()

      track1 =
        %Track{
          track_name: "track 1",
          edition: edition1
        }
        |> Repo.insert!()

      track2 =
        %Track{
          track_name: "track 2",
          edition: edition1
        }
        |> Repo.insert!()

      track3 =
        %Track{
          track_name: "track 3",
          edition: edition1
        }
        |> Repo.insert!()

      track4 =
        %Track{
          track_name: "De eerste track",
          edition: edition2
        }
        |> Repo.insert!()

      track5 =
        %Track{
          track_name: "De tweede track",
          edition: edition2
        }
        |> Repo.insert!()

      track6 =
        %Track{
          track_name: "De derde track",
          edition: edition2
        }
        |> Repo.insert!()

      travel_question7 =
        %TravelQuestion{
          description:
            "This location has been named after a theory about a cosmological model, sort of, and it will tell you the time!",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "This location has been named after a theory about a cosmological model, sort of, and it will tell you the time!",
          travel_credit_cost: 2,
          travel_point_reward: 4,
          track: track4,
          track_seq_no: 1
        }
        |> Repo.insert!()

      travel_question1 =
        %TravelQuestion{
          description:
            "Tijdens de Winterspelen van 2018 in Zuid-Korea kreeg Marcel Hirscher zijn eerste gouden Olympische medaille. Waar?",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "Tijdens de Winterspelen van 2018 in Zuid-Korea kreeg Marcel Hirscher zijn eerste gouden Olympische medaille. Waar?",
          travel_credit_cost: 2,
          travel_point_reward: 4,
          track: track4,
          track_seq_no: 2
        }
        |> Repo.insert!()

      travel_question2 =
        %TravelQuestion{
          description:
            "Ergens liggen een aantal eilanden in de vorm van visjes netjes naast elkaar. In welk land?",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "Ergens liggen een aantal eilanden in de vorm van visjes netjes naast elkaar. In welk land?",
          travel_credit_cost: 2,
          travel_point_reward: 4,
          track: track4,
          track_seq_no: 3
        }
        |> Repo.insert!()

      travel_question3 =
        %TravelQuestion{
          description:
            "Welk bedrijf zit er naast het landelijk service centrum van Scouting Nederland?",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "Welk bedrijf zit er naast het landelijk service centrum van Scouting Nederland?",
          travel_credit_cost: 2,
          travel_point_reward: 4,
          track: track4,
          track_seq_no: 4
        }
        |> Repo.insert!()

      travel_question4 =
        %TravelQuestion{
          description:
            "Wat hebben Baarn, Dwingeloo, ‘s-Gravenzande en Zeewolde met elkaar gemeen?",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question: "Wat hebben Baarn, Dwingeloo, ‘s-Gravenzande en Zeewolde met elkaar gemeen?",
          travel_credit_cost: 2,
          travel_point_reward: 4,
          track: track4,
          track_seq_no: 5
        }
        |> Repo.insert!()

      travel_question8 =
        %TravelQuestion{
          description:
            "Hij heeft ooit over het water heen gelopen, maar hier is hij dan toch daaronder gekomen.",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "Hij heeft ooit over het water heen gelopen, maar hier is hij dan toch daaronder gekomen.",
          travel_credit_cost: 4,
          travel_point_reward: 8,
          track: track5,
          track_seq_no: 1
        }
        |> Repo.insert!()

      travel_question10 =
        %TravelQuestion{
          description: "We are going to the country where “J5C 0V7” could be a postal code.",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question: "We are going to the country where “J5C 0V7” could be a postal code.",
          travel_credit_cost: 4,
          travel_point_reward: 8,
          track: track5,
          track_seq_no: 2
        }
        |> Repo.insert!()

      travel_question11 =
        %TravelQuestion{
          description:
            "Pilots have to have perfect vision. Therefore, they are often tested for their 20/20 vision. We fly to the fourth up to the sixth letter.",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "Pilots have to have perfect vision. Therefore, they are often tested for their 20/20 vision. We fly to the fourth up to the sixth letter.",
          travel_credit_cost: 4,
          travel_point_reward: 8,
          track: track5,
          track_seq_no: 3
        }
        |> Repo.insert!()

      travel_question12 =
        %TravelQuestion{
          description:
            "The closing dinner of this sports event (in status compared to Wimbledon) starts with a traditional pea soup. Travel to the venue of the main event.",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "The closing dinner of this sports event (in status compared to Wimbledon) starts with a traditional pea soup. Travel to the venue of the main event.",
          travel_credit_cost: 4,
          travel_point_reward: 8,
          track: track5,
          track_seq_no: 4
        }
        |> Repo.insert!()

      travel_question13 =
        %TravelQuestion{
          description:
            "Anni worked on her panda badge and reached millions of people with her message. Which country is she from?",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "Anni worked on her panda badge and reached millions of people with her message. Which country is she from?",
          travel_credit_cost: 4,
          travel_point_reward: 8,
          track: track5,
          track_seq_no: 5
        }
        |> Repo.insert!()

      travel_question9 =
        %TravelQuestion{
          description:
            "We gaan naar een tunnel die dient als begraafplaats voor OV bussen. Verschillende youtubers zijn er binnen geweest. Ze gebruikten een rooster in de grond als ingang. We gaan naar dat rooster.",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "We gaan naar een tunnel die dient als begraafplaats voor OV bussen. Verschillende youtubers zijn er binnen geweest. Ze gebruikten een rooster in de grond als ingang. We gaan naar dat rooster.",
          travel_credit_cost: 3,
          travel_point_reward: 4,
          track: track6,
          track_seq_no: 1
        }
        |> Repo.insert!()

      travel_question5 =
        %TravelQuestion{
          description:
            "During a funeral in this town, a cake was served that brought everyone high spirits.",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "During a funeral in this town, a cake was served that brought everyone high spirits.",
          travel_credit_cost: 3,
          travel_point_reward: 4,
          track: track6,
          track_seq_no: 2
        }
        |> Repo.insert!()

      travel_question6 =
        %TravelQuestion{
          description:
            "In 142 days, there will be a massive gathering of scouts. Lets go to the official entry point that is the closest to the campsite.",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "In 142 days, there will be a massive gathering of scouts. Lets go to the official entry point that is the closest to the campsite.",
          travel_credit_cost: 3,
          travel_point_reward: 4,
          track: track6,
          track_seq_no: 3
        }
        |> Repo.insert!()

      travel_question14 =
        %TravelQuestion{
          description:
            "We visit the stadion where a few months ago 299 ‘players’ stood very still for a very long time.",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "We visit the stadion where a few months ago 299 ‘players’ stood very still for a very long time.",
          travel_credit_cost: 3,
          travel_point_reward: 4,
          track: track6,
          track_seq_no: 4
        }
        |> Repo.insert!()

      travel_question15 =
        %TravelQuestion{
          description:
            "We’ll go to the station where an underground 'cave' is turned into a rainbow.",
          area: [
            %{"lat" => 52.13507285747798, "lng" => 12.755468749998954},
            %{"lat" => 50.8769403321742, "lng" => 10.514257812498016},
            %{"lat" => 51.91876008996218, "lng" => 6.7789062499984425},
            %{"lat" => 53.41107088600157, "lng" => 8.492773437498727}
          ],
          question:
            "We’ll go to the station where an underground 'cave' is turned into a rainbow.",
          travel_credit_cost: 3,
          travel_point_reward: 4,
          track: track6,
          track_seq_no: 5
        }
        |> Repo.insert!()

      travel_questioning15 =
        %TravelQuestioning{
          travel_question: travel_question7,
          team: team4
        }
        |> Repo.insert!()

      travel_questioning16 =
        %TravelQuestioning{
          travel_question: travel_question7,
          team: team5
        }
        |> Repo.insert!()

      travel_questioning17 =
        %TravelQuestioning{
          travel_question: travel_question7,
          team: team6
        }
        |> Repo.insert!()

      travel_questioning18 =
        %TravelQuestioning{
          travel_question: travel_question8,
          team: team4
        }
        |> Repo.insert!()

      travel_questioning19 =
        %TravelQuestioning{
          travel_question: travel_question8,
          team: team5
        }
        |> Repo.insert!()

      travel_questioning20 =
        %TravelQuestioning{
          travel_question: travel_question9,
          team: team4
        }
        |> Repo.insert!()

      travel_questioning21 =
        %TravelQuestioning{
          travel_question: travel_question1,
          team: team6
        }
        |> Repo.insert!()

      travel_questioning22 =
        %TravelQuestioning{
          travel_question: travel_question2,
          team: team6
        }
        |> Repo.insert!()

      travel_questioning23 =
        %TravelQuestioning{
          travel_question: travel_question8,
          team: team6
        }
        |> Repo.insert!()

      travel_question_answer8 =
        %TravelQuestionAnswer{
          attempt_number: 1,
          is_correct: false,
          latitude: 1.0,
          longitude: 5.0,
          timestamp: ~U[2020-02-29 13:12:07Z],
          travel_questioning: travel_questioning15
        }
        |> Repo.insert!()

      travel_question_answer9 =
        %TravelQuestionAnswer{
          attempt_number: 2,
          is_correct: true,
          latitude: 50.2,
          longitude: 9.2,
          timestamp: ~U[2020-02-29 15:32:06Z],
          travel_questioning: travel_questioning15
        }
        |> Repo.insert!()

      travel_question_answer10 =
        %TravelQuestionAnswer{
          attempt_number: 1,
          is_correct: true,
          latitude: 49.9,
          longitude: 9.7,
          timestamp: ~U[2020-02-29 16:13:18Z],
          travel_questioning: travel_questioning16
        }
        |> Repo.insert!()

      practical_task7 =
        %PracticalTask{
          description:
            "Turn a super market into a bowling contest! Find some plastic bottles, and a watermelon.",
          is_published: true,
          title: "Super(market) Bowl!",
          travel_credit_reward: 2,
          difficulty: "Easy",
          edition: edition1
        }
        |> Repo.insert!()

      practical_task8 =
        %PracticalTask{
          description:
            "Create a vehicle that can move using the power of wind! Perhaps you could attach some leafblowers to a shopping cart.",
          is_published: true,
          title: "Poor mans hovercraft",
          difficulty: "Medium",
          travel_credit_reward: 3,
          edition: edition1
        }
        |> Repo.insert!()

      practical_task9 =
        %PracticalTask{
          description:
            "Kom aanrijden met een fiets en vervang de banden zoals bij een F1 pitstop. Uiteraard verlaat de fietser de fiets niettijdens de fietsstop en kan hij met gemak doorrijden als de wielen vervangen zijn.",
          is_published: true,
          title: "F1 Fietsstop!",
          difficulty: "Hard",
          travel_credit_reward: 2,
          edition: edition2
        }
        |> Repo.insert!()

      practical_task10 =
        %PracticalTask{
          description:
            "De jaarlijkse klassieker keert ook dit jaar weer terug. Gooi een zo groot mogelijk voorwerp uit het raam van ten minste de derde verdieping. (Houdt het wel veilig).",
          is_published: true,
          title: "Uit het raam",
          difficulty: "Easy",
          travel_credit_reward: 2,
          edition: edition2
        }
        |> Repo.insert!()

      practical_task11 =
        %PracticalTask{
          description: "Bouw een bus halte om tot een compleet festival terrein inclusief band.",
          is_published: true,
          title: "Bushalte concert",
          difficulty: "Easy",
          travel_credit_reward: 2,
          edition: edition2
        }
        |> Repo.insert!()

      practical_task12 =
        %PracticalTask{
          description:
            "Maak een foto van een vallende camera waar op het scherm de camerafeed te zien is, een uitdaging, de camera mag niet aangeraakt worden.",
          is_published: true,
          title: "Foto van een Foto",
          difficulty: "Easy",
          travel_credit_reward: 2,
          edition: edition2
        }
        |> Repo.insert!()

      practical_task13 =
        %PracticalTask{
          description: "Sorteer een boekenkast niet op titel of auteur, maar op kleur.",
          is_published: true,
          title: "Boekenkast",
          difficulty: "Easy",
          travel_credit_reward: 2,
          edition: edition2
        }
        |> Repo.insert!()

      practical_task_team15 =
        %PracticalTask_Team{
          status: "Being Reviewed",
          team: team4,
          practical_task: practical_task7
        }
        |> Repo.insert!()

      practical_task_team16 =
        %PracticalTask_Team{
          status: "Done",
          team: team5,
          practical_task: practical_task7
        }
        |> Repo.insert!()

      practical_task_team17 =
        %PracticalTask_Team{
          status: "Being Reviewed",
          team: team6,
          practical_task: practical_task7
        }
        |> Repo.insert!()

      practical_task_team18 =
        %PracticalTask_Team{
          status: "To Do",
          team: team4,
          practical_task: practical_task8
        }
        |> Repo.insert!()

      practical_task_team19 =
        %PracticalTask_Team{
          status: "To Do",
          team: team5,
          practical_task: practical_task8
        }
        |> Repo.insert!()

      practical_task_team20 =
        %PracticalTask_Team{
          status: "To Do",
          team: team6,
          practical_task: practical_task8
        }
        |> Repo.insert!()

      practical_task_team21 =
        %PracticalTask_Team{
          status: "To Do",
          team: team4,
          practical_task: practical_task9
        }
        |> Repo.insert!()

      practical_task_team22 =
        %PracticalTask_Team{
          status: "To Do",
          team: team5,
          practical_task: practical_task9
        }
        |> Repo.insert!()

      practical_task_team23 =
        %PracticalTask_Team{
          status: "Being Reviewed",
          team: team6,
          practical_task: practical_task9
        }
        |> Repo.insert!()

      practical_task_team24 =
        %PracticalTask_Team{
          status: "To Do",
          team: team6,
          practical_task: practical_task10
        }
        |> Repo.insert!()

      practical_task_team25 =
        %PracticalTask_Team{
          status: "To Do",
          team: team6,
          practical_task: practical_task11
        }
        |> Repo.insert!()

      practical_task_team25 =
        %PracticalTask_Team{
          status: "To Do",
          team: team6,
          practical_task: practical_task12
        }
        |> Repo.insert!()

      practical_task_team25 =
        %PracticalTask_Team{
          status: "To Do",
          team: team6,
          practical_task: practical_task13
        }
        |> Repo.insert!()

      practical_task_submission10 =
        %PracticalTaskSubmission{
          attempt_number: 1,
          file_uuid: "38dsijo31221asd32",
          approval_state: "Rejected",
          practical_task__team: practical_task_team15
        }
        |> Repo.insert!()

      practical_task_submission11 =
        %PracticalTaskSubmission{
          attempt_number: 2,
          file_uuid: "38dsijo31221asd32",
          approval_state: "Approved",
          practical_task__team: practical_task_team15
        }
        |> Repo.insert!()

      practical_task_submission12 =
        %PracticalTaskSubmission{
          attempt_number: 1,
          file_uuid: "38dsijsad32rasd21asd32",
          approval_state: "Pending",
          practical_task__team: practical_task_team16
        }
        |> Repo.insert!()

      practical_task_submission13 =
        %PracticalTaskSubmission{
          attempt_number: 1,
          file_uuid: "384572dfgsdf32",
          approval_state: "Pending",
          practical_task__team: practical_task_team23
        }
        |> Repo.insert!()

      practical_task_submission14 =
        %PracticalTaskSubmission{
          attempt_number: 1,
          file_uuid: "38dscxvbergtdfg",
          approval_state: "Being Reviewed",
          practical_task__team: practical_task_team17
        }
        |> Repo.insert!()

      project_1 =
        %Project{
          description:
            "This is the first project. Create a 4D Rollercoaster from a couch. Two people will sit on the couch while the rest of the team make sure it steers correctly with the video.",
          title: "4D Rollercoaster",
          edition: edition1
        }
        |> Repo.insert!()

      project_2 =
        %Project{
          description:
            "This is the first project. Create a 4D Rollercoaster from a couch. Two people will sit on the couch while the rest of the team make sure it steers correctly with the video.",
          title: "4D Rollercoaster",
          edition: edition2
        }
        |> Repo.insert!()

      allow_pdf =
        %Setting{
          setting_name: "Allow PDF Download",
          value_type: "boolean",
          default_value: "true"
        }
        |> Repo.insert!()

      only_team_leader_can_buy_project =
        %Setting{
          setting_name: "Only allow Team-Leader to buy projects",
          value_type: "boolean",
          default_value: "true"
        }
        |> Repo.insert!()

      %TeamSetting{
        value: "true",
        setting: allow_pdf,
        team: team1
      }
      |> Repo.insert!()

      %TeamSetting{
        value: "true",
        setting: allow_pdf,
        team: team2
      }
      |> Repo.insert!()

      %TeamSetting{
        value: "true",
        setting: allow_pdf,
        team: team3
      }
      |> Repo.insert!()

      %TeamSetting{
        value: "true",
        setting: allow_pdf,
        team: team4
      }
      |> Repo.insert!()

      %TeamSetting{
        value: "true",
        setting: allow_pdf,
        team: team5
      }
      |> Repo.insert!()

      %TeamSetting{
        value: "true",
        setting: allow_pdf,
        team: team6
      }
      |> Repo.insert!()

      %TeamSetting{
        value: "true",
        setting: only_team_leader_can_buy_project,
        team: team1
      }
      |> Repo.insert!()

      %TeamSetting{
        value: "true",
        setting: only_team_leader_can_buy_project,
        team: team2
      }
      |> Repo.insert!()

      %TeamSetting{
        value: "true",
        setting: only_team_leader_can_buy_project,
        team: team3
      }
      |> Repo.insert!()

      %TeamSetting{
        value: "true",
        setting: only_team_leader_can_buy_project,
        team: team4
      }
      |> Repo.insert!()

      %TeamSetting{
        value: "true",
        setting: only_team_leader_can_buy_project,
        team: team5
      }
      |> Repo.insert!()

      %TeamSetting{
        value: "true",
        setting: only_team_leader_can_buy_project,
        team: team6
      }
      |> Repo.insert!()
    end
  end
end
