import { Component, OnInit } from "@angular/core";
import { ActivatedRoute, Data, Params, Router } from "@angular/router";
import { LoadingService } from "../loading.service";
import { ApiService } from "../api.service";

@Component({
  selector: "app-manager",
  templateUrl: "./manager.component.html",
  styleUrls: ["./manager.component.css"],
})
export class ManagerComponent implements OnInit {
  username;
  showLocation = false;
  showRiders = false;
  showCustomers = false;
  isCollapsed = true;
  isCollapsedOrders = true;
  selectedMonth = "5";
  selectedYear = "2020";
  newCustomers = [];
  totalOrders = [];
  totalCost = [];
  riderRole = true;
  location = [];
  customers = [];
  riders = [];
  availableLocations = [];
  currLocation = "all";
  constructor(
    private route: ActivatedRoute,
    private loadingService: LoadingService,
    private apiService: ApiService
  ) {}

  ngOnInit() {
    this.loadingService.loading.next(true);
    this.route.params.subscribe((params: Params) => {
      this.handlePeriodChange();
      this.username = params.username;
      this.apiService
        .getUserByUsername(this.username)
        .subscribe((test: any) => {
          this.loadingService.loading.next(false);
        });
    });
  }

  changeLocation() {
    this.location = [];
    this.loadingService.loading.next(true);
    this.showLocation = true;
    this.showCustomers = false;
    this.showRiders = false;
    this.apiService
      .getLocation(this.selectedMonth, this.selectedYear, this.currLocation)
      .subscribe((location: any) => {
        for (let i = 0; i < location.length; i++) {
          let tempString = location[i].filter_location_table_by_month;
          let result = tempString.substring(1, tempString.length - 1);
          let arr = result.split(",");
          this.location.push(arr);
        }
        console.log(this.location);
        this.loadingService.loading.next(false);
      });
  }

  seeLocation() {
    this.location = [];
    this.availableLocations = [];
    this.loadingService.loading.next(true);
    this.showLocation = true;
    this.showCustomers = false;
    this.showRiders = false;
    this.apiService
      .getLocation(this.selectedMonth, this.selectedYear, this.currLocation)
      .subscribe((location: any) => {
        for (let i = 0; i < location.length; i++) {
          let tempString = location[i].filter_location_table_by_month;
          let result = tempString.substring(1, tempString.length - 1);
          let arr = result.split(",");
          this.location.push(arr);
          this.availableLocations.push(arr[0]);
        }
        this.loadingService.loading.next(false);
      });
  }

  seeRiders() {
    this.riders = [];
    this.loadingService.loading.next(true);
    this.showLocation = false;
    this.showCustomers = false;
    this.showRiders = true;
    this.apiService
      .getRiders(this.selectedMonth, this.selectedYear, this.riderRole)
      .subscribe((riders: any) => {
        console.log(riders);
        for (let i = 0; i < riders.length; i++) {
          let tempString = riders[i].filter_riders_table_by_month;
          let result = tempString.substring(1, tempString.length - 1);
          let arr = result.split(",");
          this.riders.push(arr);
        }
        this.loadingService.loading.next(false);
      });
  }

  seeFTRiders() {
    this.riderRole = true;
    this.seeRiders();
  }

  seePTRiders() {
    this.riderRole = false;
    this.seeRiders();
  }

  seeCustomers() {
    this.customers = [];
    this.loadingService.loading.next(true);
    this.showLocation = false;
    this.showCustomers = true;
    this.showRiders = false;
    this.apiService
      .getCustomers(this.selectedMonth, this.selectedYear)
      .subscribe((customer: any) => {
        for (let i = 0; i < customer.length; i++) {
          let tempString = customer[i].filterbymonth;
          let result = tempString.substring(1, tempString.length - 1);
          let arr = result.split(",");
          this.customers.push(arr);
        }
        console.log(this.customers);
        this.loadingService.loading.next(false);
      });
  }

  handlePeriodChange() {
    this.newCustomers = [];
    this.totalCost = [];
    this.totalOrders = [];
    this.loadingService.loading.next(true);
    this.seeCustomers();
    this.seeLocation();
    this.seeRiders();
    this.showLocation = false;
    this.showCustomers = false;
    this.showRiders = false;
    this.apiService
      .fetchMangerStatsByMonthAndYear(this.selectedMonth, this.selectedYear)
      .subscribe((stats: any) => {
        for (let i = 0; i < stats.length; i++) {
          let tempString = stats[i].new_customers;
          let result = tempString.substring(1, tempString.length - 1);
          let arr = result.split(",");
          this.newCustomers.push(arr);
        }
        console.log(this.newCustomers);
        this.loadingService.loading.next(false);
        this.apiService
          .fetchMangerStatsByMonthAndYearOrders(
            this.selectedMonth,
            this.selectedYear
          )
          .subscribe((orders: any) => {
            for (let i = 0; i < orders.length; i++) {
              let tempString = orders[i].total_orders;
              let result = tempString.substring(1, tempString.length - 1);
              let arr = result.split(",");
              this.totalOrders.push(arr);
            }
            console.log(this.totalOrders);
            this.apiService
              .fetchMangerStatsByMonthAndYearCost(
                this.selectedMonth,
                this.selectedYear
              )
              .subscribe((cost: any) => {
                this.totalCost = cost;
                console.log(this.totalCost);
                this.loadingService.loading.next(false);
              });
          });
      });
  }
}
