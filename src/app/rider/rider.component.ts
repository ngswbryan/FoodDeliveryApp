import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Params } from "@angular/router";
import { LoadingService } from "../loading.service";
import { ApiService } from "../api.service";

@Component({
  selector: "app-rider",
  templateUrl: "./rider.component.html",
  styleUrls: ["./rider.component.css"],
})
export class RiderComponent implements OnInit {
  rider_type = "full";
  timing = [
    "1000-1100",
    "1100-1200",
    "1200-1300",
    "1300-1400",
    "1400-1500",
    "1500-1600",
    "1700-1800",
    "1800-1900",
    "1900-2000",
    "2000-2100",
    "2100-2200",
  ];

  days = ["Mon", "Tues", "Weds", "Thurs", "Fri", "Sat", "Sun"];

  username;

  constructor(
    private route: ActivatedRoute,
    private loadingService: LoadingService,
    private apiService: ApiService
  ) {}

  ngOnInit() {
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

  handle(i, j) {
    console.log(i);
    console.log(j);
  }
}
