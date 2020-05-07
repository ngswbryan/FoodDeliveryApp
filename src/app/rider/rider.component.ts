import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Params, Router } from "@angular/router";
import { LoadingService } from "../loading.service";
import { ApiService } from "../api.service";
import { FormGroup, FormControl } from "@angular/forms";
import { Observable } from "rxjs/internal/Observable";
import { ToastrService } from "ngx-toastr";
import { ThrowStmt } from "@angular/compiler";

@Component({
  selector: "app-rider",
  templateUrl: "./rider.component.html",
  styleUrls: ["./rider.component.css"],
})
export class RiderComponent implements OnInit {
  rider;
  rider_type;
  timing = [
    "1000",
    "1100",
    "1200",
    "1300",
    "1400",
    "1500",
    "1700",
    "1800",
    "1900",
    "2000",
    "2100",
    "2200",
  ];

  days = ["Mon", "Tues", "Weds", "Thurs", "Fri", "Sat", "Sun"];

  username;

  WWSForm;
  MWSForm;

  weeks = [];

  month = [];

  drafts = [];

  show = true;

  currentJob;

  selectedWeek = 1;
  selectedMonth = 5;
  selectedYear = 2020;
  selectedWeekSalary = 1;
  selectedMonthSalary = 5;
  selectedYearSalary = 2020;

  MWSMonth = 5;
  MWSYear = 2020;

  weeklyStats;
  monthlyStats;
  WWS;
  MWS;

  start = true;
  collecting = false;
  collected = false;
  omw = false;

  currentDID;

  currentWWSCommand: String = "";

  constructor(
    private route: ActivatedRoute,
    private loadingService: LoadingService,
    private apiService: ApiService,
    private router: Router,
    private toastr: ToastrService
  ) {}

  ngOnInit() {
    this.loadingService.loading.next(true);
    for (let i = 1; i < 5; i++) {
      this.weeks.push(i);
      if (i <= 12) {
        this.month.push(i);
      }
    }
    this.WWSForm = new FormGroup({
      start_hour: new FormControl(""),
      end_hour: new FormControl(""),
      day: new FormControl(""),
      week: new FormControl(""),
      month: new FormControl(""),
      year: new FormControl(""),
    });

    this.MWSForm = new FormGroup({
      days: new FormControl(""),
      shift1: new FormControl(""),
      shift2: new FormControl(""),
      shift3: new FormControl(""),
      shift4: new FormControl(""),
      shift5: new FormControl(""),
    });

    this.route.params.subscribe((params: Params) => {
      this.username = params.username;
      this.apiService
        .getUserByUsername(this.username)
        .subscribe((rider: any) => {
          console.log(rider);
          this.rider = rider;
          this.apiService.getRiderByRID(rider[0].uid).subscribe((type: any) => {
            this.rider_type = type;
            this.apiService
              .getCurrentJob(rider[0].uid)
              .subscribe((job: any) => {
                if (job.length > 0) {
                  this.currentDID = job[0].delivery_id;
                  this.apiService
                    .getCurrentJobDelivery(this.currentDID)
                    .subscribe((delivery: any) => {
                      console.log(delivery);
                      if (delivery[0].departure_time) {
                        this.start = false;
                        this.collecting = true;
                      }

                      if (delivery[0].collected_time) {
                        this.collecting = false;
                        this.collected = true;
                      }

                      if (delivery[0].delivery_start_time) {
                        this.collected = false;
                        this.omw = true;
                      }
                    });
                }
                this.currentJob = job;
                this.apiService
                  .getWeeklyStatistics(
                    rider[0].uid,
                    this.selectedWeek,
                    this.selectedMonth,
                    this.selectedYear
                  )
                  .subscribe((weekStats: any) => {
                    this.weeklyStats = weekStats;
                    console.log(this.weeklyStats);
                    this.apiService
                      .getMonthlyStatistics(
                        rider[0].uid,
                        this.selectedMonthSalary,
                        this.selectedYearSalary
                      )
                      .subscribe((monthly: any) => {
                        this.monthlyStats = monthly;
                        console.log(monthly);
                        this.apiService
                          .getWWS(
                            rider[0].uid,
                            this.selectedWeek,
                            this.selectedMonth,
                            this.selectedYear
                          )
                          .subscribe((wws: any) => {
                            this.WWS = wws;
                            console.log(wws);
                            this.apiService
                              .getMWS(
                                rider[0].uid,
                                this.selectedMonth,
                                this.selectedYear
                              )
                              .subscribe((mws: any) => {
                                console.log(mws);
                                mws.sort((a, b) =>
                                  a.week < b.week ? -1 : a.day > b.day ? 1 : 0
                                );
                                for (let i = 0; i < mws.length; i++) {
                                  if (mws[i].day == 1) {
                                    mws[i].day = "Monday";
                                  } else if (mws[i].day == 2) {
                                    mws[i].day = "Tuesday";
                                  } else if (mws[i].day == 3) {
                                    mws[i].day = "Wednesday";
                                  } else if (mws[i].day == 4) {
                                    mws[i].day = "Thursday";
                                  } else if (mws[i].day == 5) {
                                    mws[i].day = "Friday";
                                  } else if (mws[i].day == 6) {
                                    mws[i].day = "Saturday";
                                  } else {
                                    mws[i].day = "Sunday";
                                  }
                                }
                                this.MWS = mws;

                                this.loadingService.loading.next(false);
                              });
                          });
                      });
                  });
              });
          });
        });
    });
  }

  handleWWSChange() {
    this.loadingService.loading.next(true);
    this.apiService
      .getWWS(
        this.rider[0].uid,
        this.selectedWeek,
        this.selectedMonth,
        this.selectedYear
      )
      .subscribe((wws: any) => {
        this.WWS = wws;
        this.loadingService.loading.next(false);
      });
  }

  handlePeriodChange() {
    this.loadingService.loading.next(true);
    this.apiService
      .getMWS(this.rider[0].uid, this.selectedMonth, this.selectedYear)
      .subscribe((mws: any) => {
        console.log(mws);
        mws.sort((a, b) => (a.week < b.week ? -1 : a.day > b.day ? 1 : 0));
        for (let i = 0; i < mws.length; i++) {
          if (mws[i].day == 1) {
            mws[i].day = "Monday";
          } else if (mws[i].day == 2) {
            mws[i].day = "Tuesday";
          } else if (mws[i].day == 3) {
            mws[i].day = "Wednesday";
          } else if (mws[i].day == 4) {
            mws[i].day = "Thursday";
          } else if (mws[i].day == 5) {
            mws[i].day = "Friday";
          } else if (mws[i].day == 6) {
            mws[i].day = "Saturday";
          } else {
            mws[i].day = "Sunday";
          }
        }
        this.MWS = mws;

        this.loadingService.loading.next(false);
      });
  }

  handlePeriodChangeSalary() {
    this.loadingService.loading.next(true);
    this.apiService
      .getMonthlyStatistics(
        this.rider[0].uid,
        this.selectedMonthSalary,
        this.selectedYearSalary
      )
      .subscribe((stats: any) => {
        this.monthlyStats = stats;
        this.loadingService.loading.next(false);
      });
  }

  handlePeriodChangeWeeklySalary() {
    this.loadingService.loading.next(true);
    this.apiService
      .getWeeklyStatistics(
        this.rider[0].uid,
        this.selectedWeekSalary,
        this.selectedMonthSalary,
        this.selectedYearSalary
      )
      .subscribe((stats: any) => {
        this.weeklyStats = stats;
        this.loadingService.loading.next(false);
      });
  }

  addDraft() {
    if (!this.WWSForm.value.start_hour) {
      window.alert("Please choose a start hour.");
    } else if (!this.WWSForm.value.end_hour) {
      window.alert("Please choose an end hour.");
    } else if (!this.WWSForm.value.day) {
      window.alert("Please choose a day.");
    } else if (!this.WWSForm.value.month) {
      window.alert("Please choose a month.");
    } else if (!this.WWSForm.value.week) {
      window.alert("Please choose a week.");
    } else if (!this.WWSForm.value.year) {
      window.alert("Please choose a year.");
    } else {
      let newDraft = {
        start_hour: this.WWSForm.value.start_hour,
        end_hour: this.WWSForm.value.end_hour,
        day: this.WWSForm.value.day,
        week: this.WWSForm.value.week,
        month: this.WWSForm.value.month,
        year: this.WWSForm.value.year,
      };
      this.drafts.push(newDraft);
    }

    this.currentWWSCommand =
      this.currentWWSCommand +
      "INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, " +
      this.rider[0].uid +
      "," +
      this.WWSForm.value.start_hour / 100 +
      "," +
      this.WWSForm.value.end_hour / 100 +
      "," +
      this.WWSForm.value.day +
      "," +
      this.WWSForm.value.week +
      "," +
      this.WWSForm.value.month +
      "," +
      this.WWSForm.value.year +
      ");";

    console.log(this.currentWWSCommand);

    //creating a string then just keep appending
  }

  submitMWS() {
    this.loadingService.loading.next(true);
    this.apiService
      .updateMWS(
        this.rider[0].uid,
        this.MWSMonth,
        this.MWSYear,
        this.MWSForm.value
      )
      .subscribe((res: any) => {
        this.MWSForm = new FormGroup({
          days: new FormControl(""),
          shift1: new FormControl(""),
          shift2: new FormControl(""),
          shift3: new FormControl(""),
          shift4: new FormControl(""),
          shift5: new FormControl(""),
        });
        this.handlePeriodChange();
        this.loadingService.loading.next(false);
        this.toastr.show(
          "Successfully added your schedule for the selected month. You can check it in the 'Monthly Work Schedules' tab!"
        );
      });
  }

  collectingNow() {
    this.loadingService.loading.next(true);
    this.apiService
      .updateDepartureTime(this.rider[0].uid, this.currentDID)
      .subscribe((res: any) => {
        console.log(this.rider[0].uid);
        console.log(this.currentDID);
        this.start = false;
        this.collecting = true;
        this.loadingService.loading.next(false);
      });
  }

  collectedNow() {
    this.loadingService.loading.next(true);
    this.apiService
      .updateCollectedTime(this.rider[0].uid, this.currentDID)
      .subscribe((res: any) => {
        this.collected = true;
        this.collecting = false;
        this.loadingService.loading.next(false);
      });
  }

  omwNow() {
    this.loadingService.loading.next(true);
    this.apiService
      .updateDeliveryStart(this.rider[0].uid, this.currentDID)
      .subscribe((res: any) => {
        this.collected = false;
        this.omw = true;
        this.loadingService.loading.next(false);
      });
  }

  done() {
    this.loadingService.loading.next(true);
    this.apiService
      .updateDone(this.rider[0].uid, this.currentDID)
      .subscribe((res: any) => {
        console.log(this.rider[0].uid);
        console.log(this.currentDID);
        this.apiService
          .getCurrentJob(this.rider[0].uid)
          .subscribe((job: any) => {
            this.currentJob = job;
            this.omw = false;
            this.start = true;
            this.loadingService.loading.next(false);
          });
      });
  }

  submitWWS() {
    this.loadingService.loading.next(true);
    let commandObj = {
      command: this.currentWWSCommand,
    };
    console.log(commandObj.command);
    this.apiService.updateWWS(commandObj).subscribe((res: any) => {
      console.log("end req");
      this.currentWWSCommand = "";
      this.drafts = [];
      this.handleWWSChange();
      this.loadingService.loading.next(false);
    });
  }

  reset() {
    this.drafts = [];
  }
}
