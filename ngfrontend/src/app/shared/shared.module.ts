import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { LayoutModule } from '@angular/cdk/layout';

/* import { AutofocusDirective } from '../services/autofocus.directive';
import { HomeComponent } from '../home/home.component'; */

@NgModule({
  imports: [CommonModule, ReactiveFormsModule, LayoutModule],
  //declarations: [AutofocusDirective, HomeComponent],
  exports: [
    CommonModule,
    ReactiveFormsModule,
    LayoutModule
    /* AutofocusDirective,
    HomeComponent */
  ]
})
export class SharedModule {}
