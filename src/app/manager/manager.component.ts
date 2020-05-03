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

  location = [];
  customers = [];
  riders = [];
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

  seeLocation() {
    this.location = [];
    this.loadingService.loading.next(true);
    this.showLocation = true;
    this.showCustomers = false;
    this.showRiders = false;
    this.apiService.getLocation().subscribe((location: any) => {
      for (let i = 0; i < location.length; i++) {
        let tempString = location[i].location_table;
        let result = tempString.substring(1, tempString.length - 1);
        let arr = result.split(",");
        this.location.push(arr);
      }
      console.log(this.location);
      this.loadingService.loading.next(false);
    });
  }

  seeRiders() {
    this.riders = [];
    this.loadingService.loading.next(true);
    this.showLocation = false;
    this.showCustomers = false;
    this.showRiders = true;
    this.apiService.getRiders().subscribe((riders: any) => {
      for (let i = 0; i < riders.length; i++) {
        let tempString = riders[i].location_table;
        let result = tempString.substring(1, tempString.length - 1);
        let arr = result.split(",");
        this.location.push(arr);
      }
      console.log(this.location);
      this.loadingService.loading.next(false);
    });
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
