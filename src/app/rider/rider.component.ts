import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Params, Router } from "@angular/router";
import { LoadingService } from "../loading.service";
import { ApiService } from "../api.service";
import { FormGroup, FormControl } from "@angular/forms";
import { Observable } from "rxjs/internal/Observable";

@Component({
  selector: "app-rider",
  templateUrl: "./rider.component.html",
  styleUrls: ["./rider.component.css"],
})
export class RiderComponent implements OnInit {
  rider_type = "full";
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

  weeks = [];

  month = [];

  drafts = [];

  show = true;

  constructor(
    private route: ActivatedRoute,
    private loadingService: LoadingService,
    private apiService: ApiService,
    private router: Router
  ) {}

  ngOnInit() {
    for (let i = 1; i < 53; i++) {
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
    this.loadingService.loading.next(true);
    this.route.params.subscribe((params: Params) => {
      this.username = params.username;
      this.apiService
        .getUserByUsername(this.username)
        .subscribe((test: any) => {
          console.log(test);
        });
    });
    this.loadingService.loading.next(false);
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

  reset() {
    this.drafts = [];
  }
}
