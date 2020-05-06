import { Injectable } from "@angular/core";
import { HttpClient, HttpErrorResponse } from "@angular/common/http";
import { catchError, retry } from "rxjs/operators";
import { throwError, Subject, Observable, VirtualTimeScheduler } from "rxjs";
import { Router } from "@angular/router";

@Injectable()
export class ApiService {
  constructor(private http: HttpClient, public router: Router) {}

  url = "http://localhost:3002";
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
    return this.http.get(`${this.url}/users`).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  addUser(user) {
    return this.http.post(`${this.url}/users`, user).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  getUserByUsername(username) {
    return this.http.get(`${this.url}/users/${username}`).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  getStaffByUsername(uid) {
    return this.http.get(`${this.url}/staff/${uid}`).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  getPastDeliveryRating(uid) {
    return this.http.get(`${this.url}/users/rating/${uid}`).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  getPastFoodReviews(uid) {
    return this.http.get(`${this.url}/users/reviews/${uid}`).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  getListOfFoodItem(rid) {
    return this.http.get(`${this.url}/users/restaurant/${rid}`).pipe(
      retry(1),

      catchError(this.handleError)
    );
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
    return this.http
      .post(`${this.url}/users/restaurant/order/promo`, promo)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getRewardBalance(uid) {
    return this.http
      .get(`${this.url}/users/restaurant/order/rewards/${uid}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  activateRiders() {
    return this.http
      .post(`${this.url}/users/restaurant/order/activate`, "")
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getMostRecentLocation(uid) {
    return this.http
      .get(`${this.url}/users/restaurant/order/recent/${uid}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getFoodandDeliveryID(uid, rid, total_order_cost) {
    return this.http
      .get(
        `${this.url}/users/restaurant/order/${uid}/${rid}/${total_order_cost}`
      )
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getRiderName(did) {
    return this.http
      .get(`${this.url}/users/restaurant/order/ridername/${did}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getRiderRating(did) {
    return this.http
      .get(`${this.url}/users/restaurant/order/riderrating/${did}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getStartTime(did) {
    return this.http
      .get(`${this.url}/users/restaurant/order/starttime/${did}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getEndTime(did) {
    return this.http
      .get(`${this.url}/users/restaurant/order/endtime/${did}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  updateWWS(command) {
    return this.http
      .post(`${this.url}/riders/wws/draft`, command)
      .pipe(catchError(this.handleError));
  }

  updateDeliveryRating(deliveryrating) {
    return this.http
      .post(`${this.url}/users/restaurant/order/deliveryrating`, deliveryrating)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  generateTotalOrders(month, year, rid) {
    return this.http
      .get(
        `${this.url}/staff/reports/orders?rid=${rid}&month=${month}&year=${year}`
      )
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  generateTotalCost(month, year, rid) {
    return this.http
      .get(
        `${this.url}/staff/reports/cost?rid=${rid}&month=${month}&year=${year}`
      )
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  generateTopFive(rid) {
    return this.http.get(`${this.url}/staff/reports/top?rid=${rid}`).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  fetchMangerStatsByMonthAndYear(month, year) {
    return this.http
      .get(`${this.url}/manager?month=${month}&year=${year}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  fetchMangerStatsByMonthAndYearOrders(month, year) {
    return this.http
      .get(`${this.url}/manager/orders?month=${month}&year=${year}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  fetchMangerStatsByMonthAndYearCost(month, year) {
    return this.http
      .get(`${this.url}/manager/cost?month=${month}&year=${year}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getLocation(month, year, location) {
    return this.http
      .get(
        `${this.url}/manager/location?month=${month}&year=${year}&location=${location}`
      )
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getRiders(month, year) {
    return this.http
      .get(`${this.url}/manager/riders?month=${month}&year=${year}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getCurrentJob(rid) {
    return this.http.get(`${this.url}/riders/job/${rid}`).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  getCurrentJobDelivery(did) {
    return this.http.get(`${this.url}/riders/delivery/${did}`).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  getWeeklyStatistics(rid, week, month, year) {
    return this.http
      .get(
        `${this.url}/riders/weeklystats/${rid}?month=${month}&year=${year}&week=${week}`
      )
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getMonthlyStatistics(rid, month, year) {
    return this.http
      .get(`${this.url}/riders/monthlystats/${rid}?month=${month}&year=${year}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getWWS(rid, week, month, year) {
    return this.http
      .get(
        `${this.url}/riders/wws/${rid}?month=${month}&year=${year}&week=${week}`
      )
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  getMWS(rid, month, year) {
    return this.http
      .get(`${this.url}/riders/mws/${rid}?month=${month}&year=${year}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
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
    return this.http.get(`${this.url}/riders/type/${rid}`).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  getCustomers(month, year) {
    return this.http
      .get(`${this.url}/manager/customers?month=${month}&year=${year}`)
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  deleteMenuItem(fname, rid) {
    return this.http
      .patch(`${this.url}/staff/menu?fname=${fname}&rid=${rid}`, {})
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  deleteCampaign(rid) {
    return this.http.delete(`${this.url}/staff/campaigns/${rid}`).pipe(
      retry(1),

      catchError(this.handleError)
    );
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
    return this.http.get(`${this.url}/staff/campaigns/${rid}`).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  addCampaign(rid, campaign) {
    return this.http.post(`${this.url}/staff/campaigns/${rid}`, campaign).pipe(
      retry(1),

      catchError(this.handleError)
    );
  }

  updateDepartureTime(rid, did) {
    return this.http
      .patch(`${this.url}/riders/delivery/departure?rid=${rid}&did=${did}`, {})
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  updateCollectedTime(rid, did) {
    return this.http
      .patch(`${this.url}/riders/delivery/collected?rid=${rid}&did=${did}`, {})
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  updateDeliveryStart(rid, did) {
    return this.http
      .patch(`${this.url}/riders/delivery/delivery?rid=${rid}&did=${did}`, {})
      .pipe(
        retry(1),

        catchError(this.handleError)
      );
  }

  updateDone(rid, did) {
    return this.http
      .patch(`${this.url}/riders/delivery/done?rid=${rid}&did=${did}`, {})
      .pipe(
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
    window.alert("Opps something went wrong! Please try again! 😆");
    location.reload();
    return throwError(errorMessage);
  }
}
