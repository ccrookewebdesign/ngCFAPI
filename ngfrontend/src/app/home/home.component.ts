import { Component, OnInit, ViewChild } from '@angular/core';
import { MatPaginator, MatSort, MatTableDataSource } from '@angular/material';
import { Router } from '@angular/router';

import { UserService, User } from './../services/user.service';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
  @ViewChild(MatPaginator) paginator: MatPaginator;
  @ViewChild(MatSort) sort: MatSort;

  users: User[];
  displayedColumns = ['firstname', 'lastname', 'username', 'email', 'delete'];
  dataSource: any; //DataTableDataSource;

  constructor(private userService: UserService, private router: Router) {}

  ngOnInit() {
    this.userService.getUsers().subscribe(data => {
      if (!data.success) {
        if (data.errcode) {
          console.log(data);
        }
        //console.log(data.message);
      } else {
        this.users = JSON.parse(data.data);
        this.dataSource = new MatTableDataSource<User>(this.users);
        this.dataSource.paginator = this.paginator;
        this.dataSource.sort = this.sort;
      }
      console.log('this.users: ' + JSON.stringify(this.users));
    });
  }

  deleteUser(userid: number): void {
    if (confirm('Do you really want to delete this record?')) {
      this.userService.deleteUser(userid).subscribe(data => {
        if (!data.success) {
          if (data.errcode) {
            //console.log(data);
          }
          //console.log(data.message);
        } else {
          this.router.navigate(['']);
        }
        console.log('data" ' + JSON.stringify(data));
      });
    }
  }

  applyFilter(filterValue: string) {
    filterValue = filterValue.trim(); // Remove whitespace
    filterValue = filterValue.toLowerCase(); // MatTableDataSource defaults to lowercase matches
    this.dataSource.filter = filterValue;
  }
}
