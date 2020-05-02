import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Params } from '@angular/router';
import { LoadingService } from "../loading.service";
import { BsModalService, BsModalRef } from 'ngx-bootstrap/modal';
import { ModalContentComponent } from '../modal-content/modal-content.component';

@Component({
  selector: 'app-customer',
  templateUrl: './customer.component.html',
  styleUrls: ['./customer.component.css']
})

export class CustomerComponent implements OnInit {

  bsModalRef: BsModalRef;
  username;

  
  constructor(
    private router : ActivatedRoute,
    private loadingService: LoadingService,
    private modalService: BsModalService
    ) { }

  ngOnInit() {

    this.loadingService.loading.next(true);
    this.router.params.subscribe((params: Params) => {
      this.username = params.username;
    })
    this.loadingService.loading.next(false);

  }

  showYourModal() {
    const initialState = {
        parameter: 2019,
    };
    this.bsModalRef = this.modalService.show( ModalContentComponent, {initialState});
    this.bsModalRef.content.closeBtnName = 'Close';
}

}

