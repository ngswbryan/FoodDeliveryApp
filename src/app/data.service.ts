import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { THIS_EXPR } from '@angular/compiler/src/output/output_ast';

@Injectable()
export class DataService {

  private messageSource = new BehaviorSubject(false);
  currentMessage = this.messageSource.asObservable();

  private listSource = new BehaviorSubject([]);
  currentList = this.listSource.asObservable();

  private foodItemsSource = new BehaviorSubject([]);
  currentFoodItems = this.foodItemsSource.asObservable();

  private totalSource = new BehaviorSubject([]);
  currentTotal = this.totalSource.asObservable();

  constructor() { }

  changeMessage(hasOrdered: boolean) {
    this.messageSource.next(hasOrdered)
  }

  changeList(confirmedList: any[]) {
      this.listSource.next(confirmedList);
  }

  changeFoodItems(foodItems : any[]) {
    this.foodItemsSource.next(foodItems);
  }

  changeTotal(total : any) {
    this.totalSource.next(total);
  }

}