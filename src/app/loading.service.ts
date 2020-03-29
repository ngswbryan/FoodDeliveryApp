import { Injectable } from '@angular/core';
import { Subject } from 'rxjs';
import { Observable } from 'rxjs';

@Injectable()
export class LoadingService {
  loading = new Subject();
  loading$: Observable<any> = this.loading.asObservable();

}
