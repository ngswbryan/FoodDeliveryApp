import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Params, Router } from "@angular/router";
import { LoadingService } from "../loading.service";
import { ApiService } from "../api.service";
import { FormGroup, FormControl } from "@angular/forms";
import { Observable } from "rxjs/internal/Observable";
import { ToastrService } from "ngx-toastr";

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

  MWSMonth = 5;
  MWSYear = 2020;

  weeklyStats;
  monthlyStats;
  WWS;
  MWS;

  constructor(
    private route: ActivatedRoute,
    private loadingService: LoadingService,
    private apiService: ApiService,
    private router: Router,
    private toastr: ToastrService
  ) {}

  ngOnInit() {
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

    this.loadingService.loading.next(true);
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
                        this.selectedMonth,
                        this.selectedYear
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

  handlePeriodChange() {
    this.loadingService.loading.next(true);
    this.apiService
      .getMWS(this.rider[0].uid, this.selectedMonth, this.selectedYear)
      .subscribe((mws: any) => {
        console.log(mws);
        mws.sort((a, b) => (a.week < b.week ? -1 : a.day > b.day ? 1 : 0));
        this.MWS = mws;

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
        this.loadingService.loading.next(false);
        this.toastr.show(
          "Successfully added your schedule for the selected month. You can check it in the 'Monthly Work Schedules' tab!"
        );
      });
  }

  reset() {
    this.drafts = [];
  }
}
