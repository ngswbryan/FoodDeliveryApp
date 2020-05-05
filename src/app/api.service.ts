import { Injectable } from "@angular/core";
import { HttpClient, HttpErrorResponse } from "@angular/common/http";
import { catchError, retry } from "rxjs/operators";
import { throwError, Subject, Observable, VirtualTimeScheduler } from "rxjs";
import { Router } from "@angular/router";

@Injectable()
export class ApiService {
  constructor(private http: HttpClient, public router: Router) {}

  url = "";
  public erMsg = new Subject();

  getError(): Observable<any> {
    return this.erMsg.asObservable();
  }

  clearError() {
    this.erMsg.next();
  }

  indicateError() {
    this.erMsg.next(true);
  }

  getUsers() {
    return this.http.get(`${this.url}/users`);
  }

  addUser(user) {
    return this.http.post(`${this.url}/users`, user);
  }

  getUserByUsername(username) {
    return this.http.get(`${this.url}/users/${username}`);
  }

  getStaffByUsername(uid) {
    return this.http.get(`${this.url}/staff/${uid}`);
  }

  getPastDeliveryRating(uid) {
    return this.http.get(`${this.url}/users/rating/${uid}`);
  }

  getPastFoodReviews(uid) {
    return this.http.get(`${this.url}/users/reviews/${uid}`);
  }

  getListOfFoodItem(rid) {
    return this.http.get(`${this.url}/users/restaurant/${rid}`);
  }

  getRestaurants() {
    return this.http.get(`${this.url}/restaurants`);
  }

  updateOrderCount(order) {
    return this.http.post(`${this.url}/users/restaurant/order`, order).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  applyDeliveryPromo(promo) {
    return this.http.post(`${this.url}/users/restaurant/order/promo`, promo).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  getRewardBalance(uid) {
    return this.http.get(`${this.url}/users/restaurant/order/rewards/${uid}`);
  }

  activateRiders() {
    return this.http.post(`${this.url}/users/restaurant/order/activate`, "").pipe(
      retry(1),
      
      catchError(this.handleError)
    )
  }

  getMostRecentLocation(uid) {
    return this.http.get(`${this.url}/users/restaurant/order/recent/${uid}`);
  }

  getFoodandDeliveryID(uid, rid, total_order_cost) {
    return this.http.get(
      `${this.url}/users/restaurant/order/${uid}/${rid}/${total_order_cost}`
    )
  }

  generateTotalOrders(month, year, rid) {
    return this.http.get(
      `${this.url}/staff/reports/orders?rid=${rid}&month=${month}&year=${year}`
    );
  }

  generateTotalCost(month, year, rid) {
    return this.http.get(
      `${this.url}/staff/reports/cost?rid=${rid}&month=${month}&year=${year}`
    );
  }

  generateTopFive(rid) {
    return this.http.get(`${this.url}/staff/reports/top?rid=${rid}`);
  }

  fetchMangerStatsByMonthAndYear(month, year) {
    return this.http.get(`${this.url}/manager?month=${month}&year=${year}`);
  }

  fetchMangerStatsByMonthAndYearOrders(month, year) {
    return this.http.get(
      `${this.url}/manager/orders?month=${month}&year=${year}`
    );
  }

  fetchMangerStatsByMonthAndYearCost(month, year) {
    return this.http.get(
      `${this.url}/manager/cost?month=${month}&year=${year}`
    );
  }

  getLocation(month, year, location) {
    return this.http.get(
      `${this.url}/manager/location?month=${month}&year=${year}&location=${location}`
    );
  }

  getRiders(month, year) {
    return this.http.get(
      `${this.url}/manager/riders?month=${month}&year=${year}`
    );
  }

  getCurrentJob(rid) {
    return this.http.get(`${this.url}/riders/job/${rid}`);
  }

  getWeeklyStatistics(rid, week, month, year) {
    return this.http.get(
      `${this.url}/riders/weeklystats/${rid}?month=${month}&year=${year}&week=${week}`
    );
  }

  getMonthlyStatistics(rid, month, year) {
    return this.http.get(
      `${this.url}/riders/monthlystats/${rid}?month=${month}&year=${year}`
    );
  }

  getWWS(rid, week, month, year) {
    return this.http.get(
      `${this.url}/riders/wws/${rid}?month=${month}&year=${year}&week=${week}`
    );
  }

  getMWS(rid, month, year) {
    return this.http.get(
      `${this.url}/riders/mws/${rid}?month=${month}&year=${year}`
    );
  }

  updateMWS(rid, month, year, mws) {
    return this.http
      .post(`${this.url}/riders/mws/${rid}?month=${month}&year=${year}`, mws)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getRiderByRID(rid) {
    return this.http.get(`${this.url}/riders/type/${rid}`);
  }

  getCustomers(month, year) {
    return this.http.get(
      `${this.url}/manager/customers?month=${month}&year=${year}`
    );
  }

  deleteMenuItem(fname, rid) {
    return this.http.patch(
      `${this.url}/staff/menu?fname=${fname}&rid=${rid}`,
      {}
    );
  }

  deleteCampaign(rid) {
    return this.http.delete(`${this.url}/staff/campaigns/${rid}`);
  }

  addMenuItem(food) {
    return this.http.post(`${this.url}/staff/menu`, food).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  updateFoodItem(fid, rid, food) {
    return this.http
      .patch(`${this.url}/staff/menu/${fid}?rid=${rid}`, food)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getCampaigns(rid) {
    return this.http.get(`${this.url}/staff/campaigns/${rid}`);
  }

  addCampaign(rid, campaign) {
    return this.http.post(`${this.url}/staff/campaigns/${rid}`, campaign).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  handleError(error) {
    let errorMessage = "";

    if (error.error instanceof ErrorEvent) {
      // client-side error

      errorMessage = `Error: ${error.error.message}`;
    } else {
      // server-side error

      errorMessage = `Error Code: ${error.status}\nMessage: ${error.message}`;
    }
    window.alert("You've entered invalid parameters! Please try again 😆");
    location.reload();
    return throwError(errorMessage);
  }
}
