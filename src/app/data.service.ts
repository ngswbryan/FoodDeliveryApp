import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable()
export class DataService {

  private messageSource = new BehaviorSubject(false);
  currentMessage = this.messageSource.asObservable();

  private listSource = new BehaviorSubject([]);
  currentList = this.listSource.asObservable();

  constructor() { }

  changeMessage(hasOrdered: boolean) {
    this.messageSource.next(hasOrdered)
  }

  changeList(confirmedList: any[]) {
      this.listSource.next(confirmedList);
  }

}