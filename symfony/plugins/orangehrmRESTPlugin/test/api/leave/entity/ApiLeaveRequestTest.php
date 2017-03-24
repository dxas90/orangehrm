<?php
/**
 * OrangeHRM is a comprehensive Human Resource Management (HRM) System that captures
 * all the essential functionalities required for any enterprise.
 * Copyright (C) 2006 OrangeHRM Inc., http://www.orangehrm.com
 *
 * OrangeHRM is free software; you can redistribute it and/or modify it under the terms of
 * the GNU General Public License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * OrangeHRM is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program;
 * if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA  02110-1301, USA
 */


/**
 * Test class of Api/EmployeeService
 *
 * @group API
 */
use Orangehrm\Rest\Api\Leave\Entity\LeaveRequest;


class ApiLeaveRequestTest extends PHPUnit_Framework_TestCase
{

    /**
     * Set up method
     */
    protected function setUp()
    {

    }

    public function testToArray(){


        $testArray = array(

            'type' => 'Annual',
            'id' => '1',
            'date' => '2016-05-06',
            'leaveBalance' => '8',
            'numberOfDays' => '4',
            'status' => 'Cancelled',
            'comments' => '',
        );

        $leaveRequest = new LeaveRequest("1", 'Annual');

        $leaveRequest->setDate('2016-05-06');
        $leaveRequest->setLeaveBalance('8');
        $leaveRequest->setNumberOfDays('4');
        $leaveRequest->setStatus('Cancelled');
        $leaveRequest->setComments('');


        $this->assertEquals($testArray, $leaveRequest->toArray());

    }

}